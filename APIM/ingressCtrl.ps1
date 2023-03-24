# https://learn.microsoft.com/en-us/azure/aks/ingress-basic?tabs=azure-cli
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx `
  --create-namespace `
  --namespace ingress-nginx `
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz


