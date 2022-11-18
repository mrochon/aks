$TENANT = 'MngEnvMCAP679915.onmicrosoft.com'
$SUBSCRIPTION_ID = '56815821-7deb-4dce-8c2a-374756037a1e'
$INSTANCE_ID="aksmi"
$RG="$($INSTANCE_ID)-rg"
$LOCATION="westus2"
$AKS_IDENTITY="identity-$($INSTANCE_ID)"
$VM_SKU='standard_d2pds_v5' # "Standard_D2as_v5"
$AKS_NAME="aks-$($INSTANCE_ID)"
$ACR_NAME = "acr4$($INSTANCE_ID)"

az login --tenant $TENANT
az account set --subscription $SUBSCRIPTION_ID

az group create --location $LOCATION --resource-group $RG

az acr create -n $ACR_NAME -g $RG --sku Basic
az acr login --name $ACR_NAME

$AKS_IDENTITY_ID=$(az identity create --name $AKS_IDENTITY --resource-group $RG --query id -o tsv)
$spId = (az identity show --ids $AKS_IDENTITY_ID --query principalId).Replace("`"","")

az aks create --node-count 2 `
--generate-ssh-keys `
--enable-managed-identity `
--assign-identity $AKS_IDENTITY_ID `
--node-vm-size $VM_SKU `
--name $AKS_NAME `
--resource-group $RG


# Grant the role to MI
Connect-MgGraph  -Scopes "Directory.Read.All AppRoleAssignment.ReadWrite.All Application.Read.All" -TenantId $TENANT
$sp = Get-MgServicePrincipal -ServicePrincipalId $spId
$graphId = "00000003-0000-0000-c000-000000000000" #Microsoft Graph aka graph.microsoft.com, this is the one you want more than likely.
$graph = Get-MgServicePrincipal -Filter "appId eq '$graphId'"

$PermissionName = "Directory.Read.All"
$AppRole = $GraphServicePrincipal.AppRoles | Where-Object {$_.Value -eq $PermissionName -and $_.AllowedMemberTypes -contains "Application"}
New-AzureAdServiceAppRoleAssignment -ObjectId $MSI.ObjectId -PrincipalId $MSI.ObjectId -ResourceId $GraphServicePrincipal.ObjectId -Id $AppRole.Id 



