$TENANT="beitmerari.com"
$ID="lab2"
$RG="aks-$($ID)"
$AKS_NAME="aks-$($ID)-cluster"
$LOCATION="eastus"
$AKS_IDENTITY="identity-$($ID)"

$AKS_RESOURCE_GROUP=$RG

az login --tenant $TENANT
az vm list-sizes --location $LOCATION --query "[?numberOfCores == ``2``].{Name:name}" -o table
$VM_SKU="Standard_D2as_v5"
az group create --location $LOCATION --resource-group $RG

$AKS_IDENTITY_ID=$(az identity create --name $AKS_IDENTITY --resource-group $RG --query id -o tsv)

$AKS_VNET="aks-$($ID)-vnet"
$AKS_VNET_SUBNET="aks-$($ID)-subnet"
$AKS_VNET_ADDRESS_PREFIX="10.0.0.0/8"
$AKS_VNET_SUBNET_PREFIX="10.240.0.0/16"
az network vnet create --resource-group $RG `
--name $AKS_VNET `
--address-prefix $AKS_VNET_ADDRESS_PREFIX `
--subnet-name $AKS_VNET_SUBNET `
--subnet-prefix $AKS_VNET_SUBNET_PREFIX

$AKS_VNET_SUBNET_ID=$(az network vnet subnet show --resource-group $RG --vnet-name $AKS_VNET --name $AKS_VNET_SUBNET --query id -o tsv)
Write-Host "Default Subnet ID: $AKS_VNET_SUBNET_ID"

$LOG_ANALYTICS_WORKSPACE_NAME="aks-$($ID)-loganwksps"
$LOG_ANALYTICS_WORKSPACE_RESOURCE_ID=$(az monitor log-analytics workspace create --resource-group $RG --workspace-name $LOG_ANALYTICS_WORKSPACE_NAME --query id -o tsv)
Write-Host "LAW Workspace Resource ID: $LOG_ANALYTICS_WORKSPACE_RESOURCE_ID"

az aks create --resource-group $RG `
--generate-ssh-keys `
--enable-managed-identity `
--assign-identity $AKS_IDENTITY_ID `
--node-count 1 `
--enable-cluster-autoscaler `
--min-count 1 `
--max-count 3 `
--network-plugin azure `
--service-cidr 10.0.0.0/16 `
--dns-service-ip 10.0.0.10 `
--docker-bridge-address 172.17.0.1/16 `
--vnet-subnet-id $AKS_VNET_SUBNET_ID `
--node-vm-size $VM_SKU `
--nodepool-name system1 `
--enable-addons monitoring `
--workspace-resource-id $LOG_ANALYTICS_WORKSPACE_RESOURCE_ID `
--enable-ahub `
--name $AKS_NAME

az aks get-credentials --name $AKS_NAME --resource-group $RG
kubectl get nodes
kubectl get nodes -l="kubernetes.azure.com/mode=system"
az aks nodepool list --cluster-name $AKS_NAME --resource-group $RG -o table
az aks nodepool add --resource-group $RG `
--cluster-name $AKS_NAME `
--os-type Linux `
--name linux1 `
--node-count 1 `
--enable-cluster-autoscaler `
--min-count 1 `
--max-count 3 `
--mode User `
--node-vm-size $VM_SKU
kubectl get nodes
kubectl get nodes -l="kubernetes.azure.com/mode=system"
kubectl get nodes -l="kubernetes.io/os=linux"


az aks nodepool add --resource-group $AKS_RESOURCE_GROUP `
--cluster-name $AKS_NAME `
--os-type Windows `
--name win1 `
--node-count 1 `
--mode User `
--node-vm-size $VM_SKU

az aks nodepool list --cluster-name $AKS_NAME --resource-group $AKS_RESOURCE_GROUP -o table
az aks update --resource-group $AKS_RESOURCE_GROUP `
    --name $AKS_NAME `
    --cluster-autoscaler-profile `
        scale-down-delay-after-add=1m `
        scale-down-unready-time=1m `
        scale-down-unneeded-time=1m `
        skip-nodes-with-system-pods=true


# EXERCISE 2
kubectl apply -f ./yaml
kubectl get pods -o wide

# Exercise 3 - scaling
kubectl get nodes -l="kubernetes.azure.com/mode=user,kubernetes.io/os=linux"
kubectl get pods -o wide
kubectl scale --replicas=40 deploy/workload
kubectl get nodes -l="kubernetes.azure.com/mode=user,kubernetes.io/os=linux" -w

# Cleanup
Stop-AzAksCluster -resourcegroupname $AKS_RESOURCE_GROUP -name $AKS_NAME

az aks delete --resource-group $AKS_RESOURCE_GROUP --name $AKS_NAME
az monitor log-analytics workspace delete --resource-group $AKS_RESOURCE_GROUP --workspace-name $LOG_ANALYTICS_WORKSPACE_NAME
az network vnet delete --resource-group $AKS_RESOURCE_GROUP --name $AKS_VNET
az group delete --resource-group $AKS_RESOURCE_GROUP
