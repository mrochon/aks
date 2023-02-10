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
kubectl apply -f mysql-cnf-cm.yaml
kubectl apply -f mysql-dep.yaml
kubectl get pods
$pod="mysql-dep-69d8bdc7b5-9fmrq"
kubectl logs -c logreader -f $pod
kubectl exec -it -c mysql $pod -- bash


# Ingress
cd workshop/labs/module3/files
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx `
--namespace ingress-nginx --create-namespace `
--set controller.nodeSelector."kubernetes\.io/os"=linux `
--set defaultBackend.nodeSelector."kubernetes\.io/os"=linux

kubectl get svc -n ingress-nginx

kubectl create ns dev
kubectl apply -f blue-dep.yaml -f blue-svc.yaml -n dev
kubectl apply -f red-dep.yaml -f red-svc.yaml -n dev

kubectl apply -f colors-ingress.yaml -n dev
kubectl get ing -n dev

kubectl exec -ti -n dev 'blue-dep-55f9d85fcd-2qm6c' -- curl localhost:8080

kubectl apply -f default-dep.yaml -n default
kubectl apply -f default-svc.yaml -n default
kubectl apply -f default-backend.yaml -n default

az aks stop --name $AKS_NAME `
--resource-group $AKS_RESOURCE_GROUP
az group delete --resource-group $AKS_RESOURCE_GROUP







