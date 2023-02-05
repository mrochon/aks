$AKS_RESOURCE_GROUP="k8s-tech-brief-rg"
$LOCATION="westus"
$VM_SKU="Standard_D2as_v5"
$AKS_NAME="ktb-aks"
$NODE_COUNT="3"

az group create --location $LOCATION --resource-group $AKS_RESOURCE_GROUP
az aks create --node-count $NODE_COUNT `
--generate-ssh-keys `
--node-vm-size $VM_SKU `
--name $AKS_NAME `
--resource-group $AKS_RESOURCE_GROUP

az aks get-credentials --name $AKS_NAME --resource-group $AKS_RESOURCE_GROUP

kubectl get nodes

helm repo add scubakiz https://scubakiz.github.io/clusterinfo/
helm repo update
helm install clusterinfo scubakiz/clusterinfo
kubectl port-forward svc/clusterinfo 5252:5252 -n clusterinfo
# Access the app locally at http://localhost:5252:


helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
# Failed to download without the above
helm install nginx-ingress nginx-stable/nginx-ingress `
--namespace ingress-nginx --create-namespace `
--set controller.nodeSelector."kubernetes\.io/os"=linux `
--set defaultBackend.nodeSelector."kubernetes\.io/os"=linux

kubectl get svc -n ingress-nginx `
-o=custom-columns=NAME:.metadata.name,TYPE:.spec.type,IP:.status.loadBalancer.ingress[0].ip


az aks stop --name $AKS_NAME --resource-group $AKS_RESOURCE_GROUP

az aks start --name $AKS_NAME --resource-group $AKS_RESOURCE_GROUP
