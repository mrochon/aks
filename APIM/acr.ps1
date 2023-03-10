az acr create --name $ACR --resource-group $RG  --sku Basic  --admin-enabled true

az aks update --name $AKS --resource-group $RG --attach-acr $ACR

az acr check-health --name $ACR --ignore-errors --yes
az aks check-acr --resource-group $RG --name $AKS --acr $ACR

az acr login --name $ACR

kubectl create secret docker-registry myregistrykey `
   --docker-server=DOCKER_REGISTRY_SERVER `
   --docker-username=DOCKER_USER `
   --docker-password=DOCKER_PASSWORD `
   --docker-email=DOCKER_EMAIL
# add to image spec
#       imagePullSecrets:
#       - name: dockercreds