$TENANT = "beitmerari.com"
$ID = "aksdevsecops"
$RG = "rg-$($ID)"
$LOCATION = "westus"
$VM_SKU="Standard_D2as_v5"
$AKS="aks-$($ID)Cluster"
$NODE_COUNT="2"
$ACR = "mrochonacr2"


az login --tenant $TENANT


