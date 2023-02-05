$INSTANCE_ID="lab3"
$AKS_RESOURCE_GROUP="azure-$($INSTANCE_ID)-rg"
$LOCATION="westus"
$VM_SKU="Standard_D2as_v5"
$AKS_NAME="aks-$($INSTANCE_ID)"
$NODE_COUNT="3"

az login --tenant "beitmerari.com"

az group create --location $LOCATION --resource-group $AKS_RESOURCE_GROUP
az aks create --node-count $NODE_COUNT `
--generate-ssh-keys `
--node-vm-size $VM_SKU `
--name $AKS_NAME `
--resource-group $AKS_RESOURCE_GROUP

az aks get-credentials --name $AKS_NAME --resource-group $AKS_RESOURCE_GROUP

kubectl get nodes

cd .\files

kubectl apply -f mysql-initdb-cm.yaml