kubectl get nodes

cd ./apim/yaml
kubectl apply -f createNS.yaml
kubectl apply -f api.yaml -n app
kubectl apply -f svc.yaml -n app
kubectl apply -f ingress.yaml -n app

kubectl config set-context --current --namespace=default
kubectl config set-context --current --namespace=app
kubectl get pod


# 104.42.145.179   80:32294/TCP,443:31047/TCP
# https://104.42.145.179:32294/api/weatherforecast

# http://104.40.2.124:30839/api/weatherforecast
# https://104.40.2.124:30627/api/weatherforecast
