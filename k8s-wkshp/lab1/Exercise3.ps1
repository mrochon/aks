# TASK 1
kubectl label pod nginx-pod health=fair
kubectl get pods nginx-pod --show-labels

kubectl label pod nginx-pod kind=db --overwrite

#delete label
kubectl label pod nginx-pod health-

kubectl get pods --show-labels

kubectl delete pod -l target=dev