k run pod1 --image=nginx
k run pod2 --image=nginx

 k expose pod pod1 --port=80 --name service1
 k expose pod pod2 --port=80 --name service2

 openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes

 k create secret tls secure-ingress --cert=cert.pem --key=key.pem