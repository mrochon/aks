$TENANT = 'MngEnvMCAP679915.onmicrosoft.com'
$SUBSCRIPTION_ID = '56815821-7deb-4dce-8c2a-374756037a1e'
$INSTANCE_ID="lab2"
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

az vm list-sizes --location $LOCATION --query "[?numberOfCores == ``2``].{Name:name}" -o table
az vm image list-publishers -l $LOCATION  -o table
az vm image list-skus -l $LOCATION -o table | Select-String -Pattern "NotAvailableForSubscription"
az group create --location $LOCATION --resource-group $AKS_RESOURCE_GROUP

$AKS_IDENTITY_ID=$(az identity create --name $AKS_IDENTITY --resource-group $AKS_RESOURCE_GROUP --query id -o tsv)

$AKS_VNET="aks-$($INSTANCE_ID)-vnet"
$AKS_VNET_SUBNET="aks-$($INSTANCE_ID)-subnet"
$AKS_VNET_ADDRESS_PREFIX="10.0.0.0/8"
$AKS_VNET_SUBNET_PREFIX="10.240.0.0/16"

az network vnet create --resource-group $AKS_RESOURCE_GROUP `
--name $AKS_VNET `
--address-prefix $AKS_VNET_ADDRESS_PREFIX `
--subnet-name $AKS_VNET_SUBNET `
--subnet-prefix $AKS_VNET_SUBNET_PREFIX

$AKS_VNET_SUBNET_ID=$(az network vnet subnet show --resource-group $AKS_RESOURCE_GROUP --vnet-name $AKS_VNET --name $AKS_VNET_SUBNET --query id -o tsv)
Write-Host "Default Subnet ID: $AKS_VNET_SUBNET_ID"


$AKS_NAME="aks-$($INSTANCE_ID)"
Write-Host "AKS Cluster Name: $AKS_NAME"

