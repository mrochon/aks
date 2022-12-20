$PROJ_NAME = "k8stests"

kubectl config get-contexts

# Note: names are case-sensitive below
# kubectl config unset contexts.akscluster

kubectl config use-context docker-desktop
# docker run -d -p 5000:5000 --restart always --name registry registry:2

$IMAGE_NAME = "localhost:5000/$($PROJ_NAME):latest"
docker tag "$($PROJ_NAME):latest" $IMAGE_NAME
docker push $IMAGE_NAME

kubectl create deployment "$($PROJ_NAME)-deployment" --image="localhost:5000/$($PROJ_NAME)"
kubectl get pods

kubectl expose "deployment/$($PROJ_NAME)-deployment" --type="NodePort" --port 443
kubectl describe "services/$($PROJ_NAME)-deployment"

$pods = ConvertFrom-Json((kubectl get pods -o JSON) -join "")
$pod = $PODS.items[0].metadata.name
kubectl exec -ti $pod -- bash