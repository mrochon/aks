$TENANT = 'MngEnvMCAP679915.onmicrosoft.com'
$SUBSCRIPTION_ID = '56815821-7deb-4dce-8c2a-374756037a1e'
$INSTANCE_ID="lab1"
$AKS_RESOURCE_GROUP="azure-$($INSTANCE_ID)-rg"
$LOCATION="westus2"
$AKS_IDENTITY="identity-$($INSTANCE_ID)"
$VM_SKU='standard_d2pds_v5' # "Standard_D2as_v5"
$AKS_NAME="aks-$($INSTANCE_ID)"


# Task1
az login --tenant $TENANT
az account set --subscription $SUBSCRIPTION_ID

az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.Monitor
az provider register --namespace Microsoft.ManagedIdentity
az provider register --namespace Microsoft.OperationalInsights
az provider register --namespace Microsoft.OperationsManagement
az provider register --namespace Microsoft.KeyVault
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.Kubernetes

# Task 2
az vm list-sizes --location $LOCATION --query "[?numberOfCores == ``2``].{Name:name}" -o table
az vm image list-publishers -l $LOCATION  -o table
az vm image list-skus -l $LOCATION -o table | Select-String -Pattern "NotAvailableForSubscription"
az group create --location $LOCATION --resource-group $AKS_RESOURCE_GROUP

#TASK 3
Write-Host "AKS Cluster Name: $AKS_NAME"

az aks create --node-count 2 `
--generate-ssh-keys `
--node-vm-size $VM_SKU `
--name $AKS_NAME `
--resource-group $AKS_RESOURCE_GROUP

az aks delete --name $AKS_NAME --resource-group  $AKS_RESOURCE_GROUP
az aks browse --name $AKS_NAME --resource-group $AKS_RESOURCE_GROUP

az aks get-credentials --name $AKS_NAME --resource-group $AKS_RESOURCE_GROUP
kubectl get nodes