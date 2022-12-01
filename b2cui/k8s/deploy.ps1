kubectl apply -f deployment.yml
kubectl exec -ti <podname>  -- curl localhost:80/index.html
curl localhost:30001/ui/index.html