az configure --defaults location=$LOCATION
az group create --name $RG --location $LOCATION

az aks create --node-count $NODE_COUNT `
   --generate-ssh-keys `
   --node-vm-size $VM_SKU `
   --name $AKS `
   --resource-group $RG `
   --enable-addons monitoring --enable-msi-auth-for-monitoring

az aks get-credentials --name $AKS --resource-group $RG

az aks delete --name $AKS --resource-group $RG --yes
az group delete --resource-group $RG --yes
