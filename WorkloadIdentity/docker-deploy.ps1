kubectl config get-contexts
# Note: names are case-sensitive below
kubectl config unset contexts.b2cmt-aks 
kubectl config use-context docker-desktop

kubectl apply -f docker-deployment.yaml

$pods = ConvertFrom-Json((kubectl get pods -o JSON) -join "")
$pod = $PODS.items[0].metadata.name
$pod

kubectl describe pod $pod

kubectl get deployments

kubectl exec $POD -- env

