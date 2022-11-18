kubectl run busybox --image=busybox -it --rm --restart=Never -- wget ng-dep:80

kubectl expose deployment ng-dep --port=80 --type=LoadBalancer
kubectl get services --watch

kubectl run busybox --image=busybox -it --rm --restart=Never -- wget ng-dep:80

kubectl get service ng-dep -o yaml

