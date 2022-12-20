# https://blog.identitydigest.com/azuread-federate-k8s/

$TENANT = 'beitmerari.com'
$SUBSCRIPTION_ID = '56815821-7deb-4dce-8c2a-374756037a1e'
$LOCATION = "WESTUS3"
$PROJ = "akswi"
$RG = "$($PROJ)-rg"
$CLUSTER_NAME = "$($PROJ)-aks"
$ACR_SERVER = "mrochonacr"

docker tag webclientapp:latest $ACR_SERVER/webclientapp:v1
az acr login --name $ACR_SERVER
docker push $ACR_SERVER/webclientapp:v1

az login --tenant $TENANT
az account set --subscription $SUBSCRIPTION_ID

# az extension add --name aks-preview
az extension update --name aks-preview
az feature register --namespace "Microsoft.ContainerService" --name "EnableWorkloadIdentityPreview"
# above can take 10-15 mins
az feature show --namespace "Microsoft.ContainerService" --name "EnableWorkloadIdentityPreview"
az provider register --namespace Microsoft.ContainerService

az group create --name $RG --location $LOCATION
az aks create -g $RG -n $CLUSTER_NAME --node-count 1 --enable-oidc-issuer --location "${LOCATION}" --generate-ssh-keys
az aks get-credentials --resource-group $RG --name $CLUSTER_NAME
# https://github.com/Azure/AKS/issues/1517; redo az acr login -name acr
az aks update --name $CLUSTER_NAME --resource-group $RG --attach-acr $ACR_SERVER  --debug
az acr update --name $ACR_SERVER --public-network-enabled true

$AKS_OIDC_ISSUER="$(az aks show -n $CLUSTER_NAME -g $RG `
    --query "oidcIssuerProfile.issuerUrl" -otsv)"
$METADATA_URL = "$($AKS_OIDC_ISSUER).well-known/openid-configuration"
Write-Host "OIDC Metadata: $($METADATA_URL)"

kubectl apply -f k8s-deployment.yaml

az ad sp show --id "00000003-0000-0000-c000-000000000000"
$appStr = [string]::Concat((az ad app create --display-name mytestapp2))
$app = ConvertFrom-Json $appStr

$spStr = [string]::Concat((az ad sp create --id ($app.appId)))




# https://kubernetes.io/docs/concepts/storage/projected-volumes/ - to get token projection
# https://blog.devgenius.io/getting-started-with-workload-identity-in-aks-an-end-to-end-guide-547be742b327
# https://stackoverflow.com/questions/74789661/how-do-i-map-a-kubectl-create-token-to-a-callable-api/74789933#74789933
