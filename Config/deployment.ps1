kubectl apply -f config.yml
kubectl apply -f deployment.yml
kubectl get pods
kubectl exec -ti config-deployment-9d4d65b7-657nn  -- curl localhost:80/index.html
curl localhost:30001/index.html

$pods = ConvertFrom-Json((kubectl get pods -o JSON) -join "")
$pod = $PODS.items[0].metadata.name

kubectl exec -ti $pod -- bash
>more /etc/nginx/conf.d/default.conf
>...
>exit

# in a separate window start proxy
kubectl proxy

Write-Host Name of the Pod: $pod
curl http://localhost:8001/api/v1/namespaces/default/pods/$pod/