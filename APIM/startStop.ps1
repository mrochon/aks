# use constants.ps1

az aks start --name $AKS --resource-group $RG

az aks stop --name $AKS --resource-group $RG