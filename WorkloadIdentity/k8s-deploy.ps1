# https://blog.identitydigest.com/azuread-federate-k8s/

$TENANT = 'beitmerari.com'
$SUBSCRIPTION_ID = '56815821-7deb-4dce-8c2a-374756037a1e'
$LOCATION = "WESTUS3"
$PROJ = "akswi"
$RG = "$($PROJ)-rg"
$CLUSTER_NAME = "$($PROJ)-aks"
$ACR = "mrochonacr.azurecr.io"

# Make sure you are running in the right context
kubectl config get-contexts
kubectl config use-context $CLUSTER_NAME

# Setup env
# az extension add --name aks-preview
az extension update --name aks-preview
az feature register --namespace "Microsoft.ContainerService" --name "EnableWorkloadIdentityPreview"
# above can take 10-15 mins
az feature show --namespace "Microsoft.ContainerService" --name "EnableWorkloadIdentityPreview"
az provider register --namespace Microsoft.ContainerService

# Push a new docker image
docker tag webclientapp:latest $ACR/webclientapp:v1
az acr login --name $ACR  --expose-token
docker push $ACR/webclientapp:v1

# login to Azure
az login --tenant $TENANT
az account set --subscription $SUBSCRIPTION_ID

# Create an Azure cluster
az group create --name $RG --location $LOCATION
az aks create -g $RG -n $CLUSTER_NAME --node-count 1 --enable-oidc-issuer --location "${LOCATION}" --generate-ssh-keys
az aks get-credentials --resource-group $RG --name $CLUSTER_NAME

# Get username/secret from Azure ACR portal Access Keys menu. Needed because of https://github.com/Azure/AKS/issues/1517, using preview
$SECRET_NAME = "acr_secret"
$ACR_PWD = '...'
kubectl create secret docker-registry $SECRET_NAME --namespace default --docker-server=mrochonacr.azurecr.io --docker-username=mrochonacr --docker-password=$ACR_PWD
kubectl apply -f .\k8s-deployment.yaml
kubectl get services
# Go to EXTERNAL-IP:PORTS e.g. http://20.125.85.97:4080/

# The following does not work (see above)
az aks update --name $CLUSTER_NAME --resource-group $RG --attach-acr $ACR  --debug

# Get metadata
$AKS_OIDC_ISSUER="$(az aks show -n $CLUSTER_NAME -g $RG `
    --query "oidcIssuerProfile.issuerUrl" -otsv)"
$METADATA_URL = "$($AKS_OIDC_ISSUER).well-known/openid-configuration"
Write-Host "OIDC Metadata: $($METADATA_URL)"

az ad sp show --id "00000003-0000-0000-c000-000000000000"
$appStr = [string]::Concat((az ad app create --display-name mytestapp2))
$app = ConvertFrom-Json $appStr

$spStr = [string]::Concat((az ad sp create --id ($app.appId)))
# 00000003-0000-0000-c000-000000000000
# permission id: "id": "97235f07-e226-4f63-ace3-39588e11d3a1",




# https://kubernetes.io/docs/concepts/storage/projected-volumes/ - to get token projection
# https://blog.devgenius.io/getting-started-with-workload-identity-in-aks-an-end-to-end-guide-547be742b327
# https://stackoverflow.com/questions/74789661/how-do-i-map-a-kubectl-create-token-to-a-callable-api/74789933#74789933

$SERVICE_ACCOUNT_NAME = "client.api1"
(Get-Content .\test.yaml -Raw) | Write-Host