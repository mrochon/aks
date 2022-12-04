$TENANT = 'beitmerari.com'
$SUBSCRIPTION_ID = '56815821-7deb-4dce-8c2a-374756037a1e'
$INSTANCE_ID="aksmi"
$RG="$($INSTANCE_ID)-rg"
$LOCATION="westus2"
$AKS_IDENTITY="identity-$($INSTANCE_ID)"
$VM_SKU='standard_d2pds_v5' # "Standard_D2as_v5"
$CLUSTER_NAME="aks-$($INSTANCE_ID)"
$REGISTRY_NAME = "acr4$($INSTANCE_ID)"

az extension add --name aks-preview
az extension update --name aks-preview

az feature register --namespace "Microsoft.ContainerService" --name "EnableWorkloadIdentityPreview"
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/EnableWorkloadIdentityPreview')].{Name:name,State:properties.state}"
az provider register --namespace Microsoft.ContainerService

az login --tenant $TENANT
az account set --subscription $SUBSCRIPTION_ID

az group create --location $LOCATION --resource-group $RG
az aks create -g $RG -n $CLUSTER_NAME --node-count 1 --enable-oidc-issuer --enable-workload-identity --generate-ssh-keys
$AKS_OIDC_ISSUER="$(az aks show -n $CLUSTER_NAME -g $RG --query "oidcIssuerProfile.issuerUrl" -otsv)"

$IDENTITY_ID=$(az identity create --name $CLUSTER_NAME --resource-group $RG --query id -o tsv)
$spId = (az identity show --ids $IDENTITY_ID --query principalId).Replace("`"","")



# Grant the role to MI
Connect-MgGraph  -Scopes "Directory.Read.All AppRoleAssignment.ReadWrite.All Application.Read.All" -TenantId $TENANT
$sp = Get-MgServicePrincipal -ServicePrincipalId $spId
$graphId = "00000003-0000-0000-c000-000000000000" #Microsoft Graph aka graph.microsoft.com, this is the one you want more than likely.
$graph = Get-MgServicePrincipal -Filter "appId eq '$graphId'"

$PermissionName = "Directory.Read.All"
$AppRole = $GraphServicePrincipal.AppRoles | Where-Object {$_.Value -eq $PermissionName -and $_.AllowedMemberTypes -contains "Application"}
New-AzureAdServiceAppRoleAssignment -ObjectId $MSI.ObjectId -PrincipalId $MSI.ObjectId -ResourceId $GraphServicePrincipal.ObjectId -Id $AppRole.Id 


