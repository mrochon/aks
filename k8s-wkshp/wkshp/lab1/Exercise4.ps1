# Task 1
Set-Location "C:\Users\mrochon\source\repos\aks\k8s-wkshp\lab1\yaml"
kubectl apply -f ng-dep.yaml
kubectl apply -f ng-svc.yaml

kubectl get all --show-labels

kubectl get svc


az aks delete --name $AKS_NAME --resource-group $AKS_RESOURCE_GROUP
