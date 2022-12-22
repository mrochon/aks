kubectl config get-contexts
kubectl config use-context minikube

minikube delete

minikube start
minikube addons enable metrics-server
minikube dashboard

kubectl get po -A

# To point your terminal to use the docker daemon inside minikube run this
& minikube -p minikube docker-env --shell powershell | Invoke-Expression

minikube image load webclientapp:latest
minikube image list
minikube cache delete webclientapp:v1

$IMAGE = "docker.io/library/webclientapp:latest"
$SERVICE_ACCOUNT = "client.app1"

kubectl apply -f .\configMap.yaml
$yaml = $ExecutionContext.InvokeCommand.ExpandString((Get-Content .\serviceaccount.yaml | Out-String))
$yaml | kubectl apply -f -

$yaml = $ExecutionContext.InvokeCommand.ExpandString((Get-Content .\deployment.yaml | Out-String))
$yaml | kubectl apply -f -
# Minikube does not have integrated LoadBalancer: https://stackoverflow.com/questions/44110876/kubernetes-service-external-ip-pending
kubectl expose deployment api-client --type=NodePort --port=8080
kubectl get services
kubectl get pods
kubectl exec -ti 
# ------------------------------------------------------------------------


kubectl create deployment hello-minikube --image=kicbase/echo-server:1.0
kubectl expose deployment hello-minikube --type=NodePort --port=8080
kubectl get services hello-minikube
# Use this and then browse to localhost:7080
kubectl port-forward service/hello-minikube 7080:8080

kubectl delete deployment hello-minikube

minikube image load webclientapp:latest
minikube cache list
minikube cache delete <image name>

kubectl expose deployment api-client --type=NodePort --port=8080
kubectl get services hello-minikube
# Use this and then browse to localhost:7080
kubectl port-forward service/api-client 7080:8080

more /service-account/token
