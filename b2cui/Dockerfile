FROM nginx:latest
EXPOSE 80
EXPOSE 443
LABEL author="mrochon@microsoft.com"

# https://stackoverflow.com/questions/10175812/how-to-generate-a-self-signed-ssl-certificate-using-openssl
RUN openssl req -x509 -nodes -newkey rsa:4096 -keyout /etc/nginx/conf.d/localhost.key -out /etc/nginx/conf.d/localhost.crt \
     -sha256 -days 365 -subj "/C=US/ST=WA/L=Seattle/O=Your Company, Inc./OU=IT/CN=localhost"
COPY default.conf /etc/nginx/conf.d/
CMD ["nginx", "-g", "daemon off;"]
