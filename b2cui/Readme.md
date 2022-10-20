```
docker build -t b2cui:latest .
docker run -d -it --name b2cui -p 80:80 -v $pwd/ui:/usr/share/nginx/html/ui b2cui:latest
docker run -d -it --name b2cui -p 80:80443:443 -v $pwd/ui:/usr/share/nginx/html/ui b2cui:latest


docker cp nginx-base:/etc/nginx/conf.d/default.conf ./default.conf
docker cp ./ui/ nginx-base:/usr/share/nginx/html  
docker exec -it b2cui ls /usr/share/nginx/html
```

To apply config changes:
```
docker exec -it nginx-base service nginx reload
```


```PowerShell
New-SelfSignedCertificate `
    -KeyExportPolicy Exportable `
    -Subject "CN=localhost" `
    -KeyAlgorithm RSA `
    -KeyLength 2048 `
    -KeyUsage DigitalSignature `
    -NotAfter (Get-Date).AddMonths(12) `
    -CertStoreLocation "Cert:\CurrentUser\My"
```