$ACR = "mrochonacr2.azurecr.io"
az acr login --name $ACR
docker tag weatherforecast:dev $ACR/weatherforecast:v1
docker push $ACR/weatherforecast:v1
az acr repository list --name $ACR --output table
az acr repository show-tags --name $ACR --repository weatherforecast --output table

docker tag weatherforecast:latest rochonm/weatherforecast:v2
docker push rochonm/weatherforecast:v2