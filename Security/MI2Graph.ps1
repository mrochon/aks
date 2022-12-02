$TENANT = 'MngEnvMCAP679915.onmicrosoft.com'
$SUBSCRIPTION_ID = '56815821-7deb-4dce-8c2a-374756037a1e'
$INSTANCE_ID="aksmi"
$RG="$($INSTANCE_ID)-rg"
$LOCATION="westus2"
$VM_SKU='standard_d2pds_v5' # "Standard_D2as_v5"
$CLUSTER_NAME="aks-$($INSTANCE_ID)"
$ACR_NAME = "acr4$($INSTANCE_ID)"
$MI_NAME = "$($INSTANCE_ID)-identity"

az login --tenant $TENANT
az account set --subscription $SUBSCRIPTION_ID

az group create --location $LOCATION --resource-group $RG

# https://learn.microsoft.com/en-us/azure/aks/learn/tutorial-kubernetes-workload-identity?source=recommendations
# https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster
az extension add --name aks-preview
az extension update --name aks-preview

az feature register --namespace "Microsoft.ContainerService" --name "EnableWorkloadIdentityPreview"
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/EnableWorkloadIdentityPreview')].{Name:name,State:properties.state}"
az provider register --namespace Microsoft.ContainerService

az aks create -g $RG -n $CLUSTER_NAME --node-count 1 --enable-oidc-issuer --enable-workload-identity --generate-ssh-keys
export AKS_OIDC_ISSUER="$(az aks show -n $CLUST_NAME -g $RG --query "oidcIssuerProfile.issuerUrl" -otsv)"
az aks show --resource-group $rg --name $CLUSTER_NAME --query "oidcIssuerProfile.issuerUrl" -otsv

# Create a managed identity to act as trusted issuer
az identity create --name $MI-NAME --resource-group $RG --location $LOCATION --subscription $SUBSCRIPTION_ID
export USER_ASSIGNED_CLIENT_ID="$(az identity show --resource-group $RG --name $MI_NAME --query 'clientId' -otsv)"

# Create a service account
az aks get-credentials -n myAKSCluster -g "${RESOURCE_GROUP}"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: ${USER_ASSIGNED_CLIENT_ID}
  labels:
    azure.workload.identity/use: "true"
  name: ${SERVICE_ACCOUNT_NAME}
  namespace: ${SERVICE_ACCOUNT_NAMESPACE}
EOF

# Create a federated credential
az identity federated-credential create --name ${FICID} --identity-name ${UAID} --resource-group ${RESOURCE_GROUP} --issuer ${AKS_OIDC_ISSUER} --subject system:serviceaccount:${SERVICE_ACCOUNT_NAMESPACE}:${SERVICE_ACCOUNT_NAME}

# Give Graph permission
Connect-MgGraph  -Scopes "Directory.Read.All AppRoleAssignment.ReadWrite.All Application.Read.All" -TenantId $TENANT
New-

$sp = Get-MgServicePrincipal -ServicePrincipalId $spId
$graphId = "00000003-0000-0000-c000-000000000000" #Microsoft Graph aka graph.microsoft.com, this is the one you want more than likely.
$graph = Get-MgServicePrincipal -Filter "appId eq '$graphId'"
$reqRoles = @("Application.Read.All")
foreach($r in $graph.AppRoles | Where-Object {$reqRoles.Contains($_.value)}) {
    Write-Host "Assigning $($r.value) to Managed Identity Service Principal $($spId)"
    $params = @{
        PrincipalId = $spid
        ResourceId = $graph.id
        AppRoleId = $r.id
    }    
    New-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $graph.Id -BodyParameter $params
}

az acr create -n $ACR_NAME -g $RG --sku Basic
az acr login --name $ACR_NAME
