kubectl config get-contexts
# Note: names are case-sensitive below
kubectl config unset contexts.akscluster

kubectl config use-context docker-desktop
docker run -d -p 5000:5000 --restart always --name registry registry:2

docker tag webapp:dev localhost:5000/webapp
docker push localhost:5000/webapp