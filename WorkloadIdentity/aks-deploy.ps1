# https://blog.identitydigest.com/azuread-federate-k8s/

$AAD_TENANT = 'beitmerari.com'
$SUBSCRIPTION_ID = '56815821-7deb-4dce-8c2a-374756037a1e'
$LOCATION = "WESTUS3"
$PROJ = "akswi"
$RG = "$($PROJ)-rg"
$CLUSTER_NAME = "$($PROJ)-aks"
$REPO = "mrochonacr.azurecr.io"
$IMAGE = "$($REPO)/webclientapp:v1"
$SERVICE_ACCOUNT = "client.app1"
$AAD_APP_NAME = "K8S Client App"
$AAD_APP_ID = "6f377fa5-9da4-47bc-8fca-090b4a361870"

# login to Azure
az login --tenant $AAD_TENANT
az account set --subscription $SUBSCRIPTION_ID

# Setup env
# az extension add --name aks-preview
az extension update --name aks-preview
az feature register --namespace "Microsoft.ContainerService" --name "EnableWorkloadIdentityPreview"
# above can take 10-15 mins
az feature show --namespace "Microsoft.ContainerService" --name "EnableWorkloadIdentityPreview"
az provider register --namespace Microsoft.ContainerService

# Create an Azure cluster
az group create --name $RG --location $LOCATION
az aks create -g $RG -n $CLUSTER_NAME --node-count 1 --enable-oidc-issuer --location "${LOCATION}" --generate-ssh-keys
az aks get-credentials --resource-group $RG --name $CLUSTER_NAME

# Make sure you are running in the right context
kubectl config get-contexts
kubectl config use-context $CLUSTER_NAME

# Push a new docker image
az acr login --name $REPO 
docker tag webclientapp:latest $REPO/webclientapp:v2
docker push $REPO/webclientapp:v2

# Get username/secret from Azure ACR portal Access Keys menu. Needed because of https://github.com/Azure/AKS/issues/1517, using preview
$SECRET_NAME = "acr_secret"
$REPO_PWD = '...'
kubectl create secret docker-registry $SECRET_NAME --namespace default --docker-server=mrochonacr.azurecr.io --docker-username=mrochonacr --docker-password=$REPO_PWD

# The following does not work (see above)
# az aks update --name $CLUSTER_NAME --resource-group $RG --attach-acr $REPO  --debug

# Setup app in AAD (manually for now, some starter code below). Use the url below to complete workflow Identity setup for this app
# Get metadata
$AKS_OIDC_ISSUER="$(az aks show -n $CLUSTER_NAME -g $RG `
    --query "oidcIssuerProfile.issuerUrl" -otsv)"
$METADATA_URL = "$($AKS_OIDC_ISSUER).well-known/openid-configuration"
Write-Host "OIDC Metadata: $($METADATA_URL)"

# k8s APIs
# Update yaml with env variables and apply
$ExecutionContext.InvokeCommand.ExpandString((Get-Content .\configMap.yaml | Out-String)) | kubectl apply -f -
$ExecutionContext.InvokeCommand.ExpandString((Get-Content .\deployment.yaml | Out-String)) | kubectl apply -f -

kubectl get pods
kubectl get services
# Go to EXTERNAL-IP:PORTS e.g. http://20.125.85.97:4080/




# TBD. Incomplete!!!
az ad sp show --id "00000003-0000-0000-c000-000000000000"
# App registration
$app = ConvertFrom-Json ([string]::Concat((az ad app create --display-name $($AAD_APP_NAME)))))
$sp = ConvertFrom-Json ([string]::Concat((az ad sp create --id ($app.appId))))

# 00000003-0000-0000-c000-000000000000
# permission id: "id": "97235f07-e226-4f63-ace3-39588e11d3a1",


# https://kubernetes.io/docs/concepts/storage/projected-volumes/ - to get token projection
# https://blog.devgenius.io/getting-started-with-workload-identity-in-aks-an-end-to-end-guide-547be742b327
# https://stackoverflow.com/questions/74789661/how-do-i-map-a-kubectl-create-token-to-a-callable-api/74789933#74789933

