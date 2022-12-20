kubectl get po -A
kubectl config get-contexts

alias kubectl="minikube kubectl --"

minikube dashboard

kubectl create deployment hello-minikube --image=kicbase/echo-server:1.0
kubectl expose deployment hello-minikube --type=NodePort --port=8080
kubectl get services hello-minikube
# Use this and then browse to localhost:7080
kubectl port-forward service/hello-minikube 7080:8080

kubectl delete deployment hello-minikube

& minikube -p minikube docker-env --shell powershell | Invoke-Expression

minikube image load webclientapp:latest
minikube cache list
minikube cache delete <image name>

kubectl apply -f .\minikube-deployment.yaml
kubectl expose deployment api-client --type=NodePort --port=8080
kubectl get services hello-minikube
# Use this and then browse to localhost:7080
kubectl port-forward service/api-client 7080:8080

more /service-account/token
