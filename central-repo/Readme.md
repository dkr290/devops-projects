# mongodb secret

openssl rand -base64 756 > mongodb-keyfile
chmod 600 mongodb-keyfile
kubectl create secret generic mongodb-keyfile --from-file=mongodb-keyfile -n mongodb
