$BASE_SOURCE_DIR = 'C:\Users\mrochon\OneDrive - Microsoft\Workshops\K8s Technical Brief\K8s-Labs\Labs\'
$MOD_SOURCE_DIR = "$($BASE_SOURCE_DIR)Module1"
Set-Location $MOD_SOURCE_DIR

kubectl apply -f simple-pod.yaml

kubectl get pods

kubectl apply -f simple-pod2.yaml
kubectl get pods

kubectl get pods --show-labels

# did not list anything!!!
kubectl get pod -l kind=web
kubectl get pod -l kind=db

kubectl get pods nginx-pod -o yaml | Get-Content
Get-Content mypod.yaml
