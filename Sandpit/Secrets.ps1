kubectl create secret -n mr-sample1  generic db-user-pass `
    --from-literal=username=admin `
    --from-literal=password='S!B\*d$zDsb='

kubectl delete -n mr-sample1 secret db-user-pass