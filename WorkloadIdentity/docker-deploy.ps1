kubectl config get-contexts
# Note: names are case-sensitive below
kubectl config unset contexts.b2cmt-aks 
kubectl config use-context docker-desktop

kubectl apply -f configMap.yaml
kubectl apply -f docker-deployment.yaml

$pods = ConvertFrom-Json((kubectl get pods -o JSON) -join "")
$pod = $PODS.items[0].metadata.name
$pod

kubectl describe pod $pod

kubectl get deployments
kubectl expose "deployment/api-client" --type="NodePort" --port 8080
kubectl get services

kubectl exec $POD -- env
kubectl exec -ti $POD -- bash


