$TENANT = 'beitmerari.com'
$SUBSCRIPTION_ID = '56815821-7deb-4dce-8c2a-374756037a1e'
$LOCATION = "WESTUS3"
$PROJ = "b2cmt"
$RG = "$($PROJ)aks-rg"
$IDENTITY = "$($PROJ)-api-identity"
$AKS_CLUSTER_NAME = "$($PROJ)-aks"
$ACR_SERVER = "mrochonacr.azurecr.io"
$SERVICE_ACCOUNT_NAME = "graph-client.com"
$SERVICE_ACCOUNT_NAMESPACE = "default"
$FEDERATED_IDENTITY_NAME = "b2cmt-aks-api"

docker tag restfunctions:latest $ACR_SERVER/b2cmtapi:v1
az acr login --name $ACR_SERVER
docker push $ACR_SERVER/b2cmtapi:v1

az login --tenant $TENANT
az account set --subscription $SUBSCRIPTION_ID

az extension add --name aks-preview
az extension update --name aks-preview
az feature register --namespace "Microsoft.ContainerService" --name "EnableWorkloadIdentityPreview"
# above can take 10-15 mins
az feature show --namespace "Microsoft.ContainerService" --name "EnableWorkloadIdentityPreview"
az provider register --namespace Microsoft.ContainerService

az group create --name $RG --location $LOCATION
az aks create -g $RG -n $AKS_CLUSTER_NAME --node-count 1 --enable-oidc-issuer --enable-workload-identity --generate-ssh-keys

az identity create --name $IDENTITY --resource-group $RG `
    --location $LOCATION --subscription $SUBSCRIPTION_ID

$USER_ASSIGNED_CLIENT_ID="$(az identity show `
    --resource-group $RG --name $IDENTITY --query 'clientId' -otsv)"
# Give AAD permissions to the client

$AKS_OIDC_ISSUER="$(az aks show -n $AKS_CLUSTER_NAME -g $RG `
    --query "oidcIssuerProfile.issuerUrl" -otsv)"
$METADATA_URL = "$($AKS_OIDC_ISSUER).well-known/openid-configuration"
Write-Host "OIDC Metadata: $($METADATA_URL)"

az aks get-credentials -n $AKS_CLUSTER_NAME -g $RG

# fix up and ..

"apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: $($USER_ASSIGNED_CLIENT_ID)
  labels:
    azure.workload.identity/use: ""true""
  name: $($SERVICE_ACCOUNT_NAME)
  namespace: $($SERVICE_ACCOUNT_NAMESPACE)" | kubectl apply -f -

# ----------

az identity federated-credential create --name $FEDERATED_IDENTITY_NAME `
    --identity-name $IDENTITY --resource-group $RG `
    --issuer ${AKS_OIDC_ISSUER} `
    --subject system:serviceaccount:${SERVICE_ACCOUNT_NAMESPACE}:${SERVICE_ACCOUNT_NAME}

kubectl create token $SERVICE_ACCOUNT_NAME --audience @( "api://AzureADTokenExchange")
# 
# 1. Register an app in AAD and give it whatever API permissions are needed
# 2. Use the above token with client creds to exchange it for an API token: https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-client-creds-grant-flow#third-case-access-token-request-with-a-federated-credential
# ---------------------------------------------------------------------------------------


# https://blog.devgenius.io/getting-started-with-workload-identity-in-aks-an-end-to-end-guide-547be742b327
