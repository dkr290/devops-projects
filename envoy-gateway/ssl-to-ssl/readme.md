# generate for the test

```

openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=example Inc./CN=example.com' -keyout ca.key -out ca.crt

cat > openssl.conf  <<EOF
[req]
req_extensions = v3_req
prompt = no

[v3_req]
keyUsage = keyEncipherment, digitalSignature
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = www.example.com
EOF

openssl req -out www.example.com.csr -newkey rsa:2048 -nodes -keyout www.example.com.key -subj "/CN=www.example.com/O=example organization"
openssl x509 -req -days 365 -CA ca.crt -CAkey ca.key -set_serial 0 -in www.example.com.csr -out www.example.com.crt -extfile openssl.conf -extensions v3_req

kubectl create secret tls example-cert --key=www.example.com.key --cert=www.example.com.crt


kubectl create configmap example-ca --from-file=ca.crt



openssl genrsa -out gateway.key 2048
openssl req -x509 -new -nodes -key gateway.key -sha256 -days 1825 -out gateway.crt -subj "/CN=gateway.example.com"
kubectl create secret tls gateway-tls-cert --key=gateway.key --cert=gateway.crt
```
