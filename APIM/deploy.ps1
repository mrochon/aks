$TENANT = "beitmerari.com"
$ID = "aksdevsecops"
$RG = "rg-$($ID)"
$LOCATION = "westus"
$VM_SKU="Standard_D2as_v5"
$AKS="aks-$($ID)Cluster"
$NODE_COUNT="2"
$ACR = "mrochonacr2"

az login --tenant $TENANT

az configure --defaults location=$LOCATION
az group create --name $RG --location $LOCATION

az acr create --name $ACR --resource-group $RG  --sku Basic  --admin-enabled true
az acr login --name $ACR

az aks create --node-count $NODE_COUNT `
   --generate-ssh-keys `
   --node-vm-size $VM_SKU `
   --name $AKS `
   --resource-group $RG `
   --enable-managed-identity `
   --enable-addons monitoring --enable-msi-auth-for-monitoring

az aks get-credentials --name $AKS --resource-group $RG
az aks update --name $AKS --resource-group $RG --attach-acr $ACR

kubectl get nodes
az acr check-health --name $ACR --ignore-errors --yes
az aks check-acr --resource-group $RG --name $AKS --acr $ACR

kubectl create secret docker-registry myregistrykey `
   --docker-server=DOCKER_REGISTRY_SERVER `
   --docker-username=DOCKER_USER `
   --docker-password=DOCKER_PASSWORD `
   --docker-email=DOCKER_EMAIL
# add to image spec
#       imagePullSecrets:
#       - name: dockercreds

cd ./apim/yaml
kubectl apply -f createNS.yaml
kubectl apply -f deploy-api.yaml
kubectl config set-context --current --namespace=app
kubectl get pod

az aks stop --name $AKS --resource-group $RG
az aks start --name $AKS --resource-group $RG

# Create a deployer ServicePrincipal
$appName = "Deployer $($ID)"
Write-Host ("Registered app: {0}" -f $appName)
$appId=$(az ad app create --display-name $appName --query appId --output tsv)
echo $appId
$spId=$(az ad sp create --id $appId --query id --output tsv)
Write-Host "   Created Serviceprincipal $($spId)" 
$subscriptionId=$(az account show --query id --output tsv)
Write-Host "Subscription: $($subscriptionId)"
az role assignment create --role owner --subscription $subscriptionId `
   --assignee-object-id  $spId `
   --assignee-principal-type ServicePrincipal `
   --scope "/subscriptions/$($subscriptionId)"






# Cleanup
az group delete --name $RG
az ad app delete --id $appId
az ad sp delete --id $spId



az aks update -n myAKSCluster -g myResourceGroup --attach-acr <acr-name> # Attach using acr-resource-id az aks update -n myAKSCluster -g myResourceGroup --attach-acr <acr-resource-id>