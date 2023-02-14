$AKS_RESOURCE_GROUP="k8s-demo"
$LOCATION="westus"
$VM_SKU="Standard_D2as_v5"
$AKS_NAME="mr-demo-aks"
$NODE_COUNT="2"

az group create --location $LOCATION --resource-group $AKS_RESOURCE_GROUP
az aks create --node-count $NODE_COUNT `
--generate-ssh-keys `
--node-vm-size $VM_SKU `
--name $AKS_NAME `
--resource-group $AKS_RESOURCE_GROUP

az aks get-credentials --name $AKS_NAME --resource-group $AKS_RESOURCE_GROUP

kubectl get nodes

# https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

kubectl apply -f ./user.yaml
kubectl -n kubernetes-dashboard create token admin-user

kubectl describe services -n mr-sample1 mr-sample1

kubectl proxy
# http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

az aks stop --name $AKS_NAME --resource-group $AKS_RESOURCE_GROUP

az aks start --name $AKS_NAME --resource-group $AKS_RESOURCE_GROUP