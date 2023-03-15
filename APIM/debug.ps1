kubectl port-forward pod/weather-api-99c9c7fd6-t7t5n  8080:80
kubectl port-forward service/api-svc 8080:8100

# localhost:8080/weatherforecast

kubectl get service ingress-nginx-controller --namespace=ingress-nginx
# 104.42.145.179   80:32294/TCP,443:31047/TCP 
# 104.42.145.179:32294/TCP,443:31047/TCP
# 104.42.145.179   80:32294/TCP,443:31047/TCP


kubectl get pods --namespace ingress-nginx
kubectl logs ingress-nginx-controller-89758f7c6-plb95 --namespace ingress-nginx

