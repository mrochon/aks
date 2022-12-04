kubectl config get-contexts
docker tag restfunctions:latest localhost:5000/mtapi:1.0.0

kubectl apply -f config.yaml
kubectl apply -f deployment.yaml
kubectl delete -f deployment.yaml

$pods = ConvertFrom-Json((kubectl get pods -o JSON) -join "")
$pod = $PODS.items[0].metadata.name
$pod

kubectl describe pod $pod

kubectl get deployments

kubectl exec $POD -- env
kubectl exec -ti $POD -- bash

kubectl expose deployment b2cmt --port=443 --type=NodePort
kubectl get service b2cmt
# use localhost:<portnumber>/health/props