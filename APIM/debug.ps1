kubectl get svc -n ingress-nginx

kubectl get pods -n app
kubectl port-forward pod/weather-api-99c9c7fd6-l4hfb  8080:80 -n app
curl -kL http

kubectl get svc -n app
kubectl port-forward 10.0.40.161  8080:80 -n app

# localhost:8080/weatherforecast

kubectl get service --namespace=ingress-nginx
# 104.42.145.179   80:32294/TCP,443:31047/TCP 
# 104.42.145.179:32294/TCP,443:31047/TCP
# 104.42.145.179   80:32294/TCP,443:31047/TCP

kubectl logs nginx-ingress-ingress-nginx-controller-7b5fd4596d-gxj2k --namespace ingress-nginx


kubectl exec -ti ingress-nginx-controller-89758f7c6-4b8kc -n ingress-nginx -- bash

kubectl get pods -n ingress-nginx
kubectl logs nginx-ingress-ingress-nginx-controller-7b5fd4596d-sb4lh -n ingress-nginx
