# Create a deployer ServicePrincipal
$appName = "Deployer $($ID)"
Write-Host ("Registered app: {0}" -f $appName)
$appId=$(az ad app create --display-name $appName --query appId --output tsv)
echo $appId
$spId=$(az ad sp create --id $appId --query id --output tsv)
Write-Host "   Created Serviceprincipal $($spId)" 
$subscriptionId=$(az account show --query id --output tsv)
Write-Host "Subscription: $($subscriptionId)"
az role assignment create --role owner --subscription $subscriptionId `
   --assignee-object-id  $spId `
   --assignee-principal-type ServicePrincipal `
   --scope "/subscriptions/$($subscriptionId)"

