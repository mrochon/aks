docker tag restfunctions:latest localhost:5000/restfunctions:1.0.0

kubectl apply -f deployment.yaml
kubectl delete -f deployment.yaml

$pods = ConvertFrom-Json((kubectl get pods -o JSON) -join "")
$pod = $PODS.items[0].metadata.name

kubectl describe pod $pod

kubectl expose deployment webapi --port=443 --type=NodePort
kubectl get service webapi
# use localhost:<portnumber>/health/props