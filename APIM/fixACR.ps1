$ID = "aksdevsecops"
$RG = "rg-$($ID)"
$AKS="aks-$($ID)Cluster"
$ACR = "mrochonacr2"
$SUBSCRIPTION_ID = "56815821-7deb-4dce-8c2a-374756037a1e"


$role_id=$(az role definition list `
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG/providers/Microsoft.ContainerRegistry/registries/$ACR" `
  --name AcrPull `
  --query "[0].id" -o tsv)

$object_id=$(az aks show `
  -g $RG `
  -n $AKS `
  --query "identityProfile.kubeletidentity.objectId" -o tsv)

az role assignment create `
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG/providers/Microsoft.ContainerRegistry/registries/$ACR" `
  --role "$role_id" `
  --assignee-object-id "$object_id" `
  --assignee-principal-type ServicePrincipal