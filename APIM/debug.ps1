kubectl port-forward pod/weather-api-99c9c7fd6-2v5cf  8080:80 -n app
curl -kL http

# localhost:8080/weatherforecast

kubectl get service ingress-nginx-controller --namespace=ingress-nginx
# 104.42.145.179   80:32294/TCP,443:31047/TCP 
# 104.42.145.179:32294/TCP,443:31047/TCP
# 104.42.145.179   80:32294/TCP,443:31047/TCP


kubectl get pods --namespace ingress-nginx
kubectl logs ingress-nginx-controller-89758f7c6-4b8kc --namespace ingress-nginx

kubectl exec -ti ingress-nginx-controller-89758f7c6-4b8kc -n ingress-nginx -- bash
