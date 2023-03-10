helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install nginx-ingress ingress-nginx/ingress-nginx `
--namespace ingress-nginx --create-namespace `
--set controller.nodeSelector."kubernetes\.io/os"=linux `
--set defaultBackend.nodeSelector."kubernetes\.io/os"=linux

# per https://kubernetes.github.io/ingress-nginx/deploy/#quick-start

helm upgrade --install ingress-nginx ingress-nginx `
  --repo https://kubernetes.github.io/ingress-nginx `
  --namespace ingress-nginx --create-namespace

kubectl get service ingress-nginx-controller --namespace=ingress-nginx
kubectl get svc -n ingress-nginx


# demo: access via http://demo.localdev.me:8080/
kubectl create deployment demo --image=httpd --port=80
kubectl expose deployment demo
kubectl create ingress demo-localhost --class=nginx `
  --rule="demo.localdev.me/*=demo:80"
kubectl port-forward --namespace=ingress-nginx service/ingress-nginx-controller 8080:80

kubectl delete deployment demo
kubectl delete ingress demo-localhost