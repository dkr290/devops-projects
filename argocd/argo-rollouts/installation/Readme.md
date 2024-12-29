# installation with helm

## using this in k3d cluster

- helm repo add argo https://argoproj.github.io/argo-helm
- helm install ar argo/argo-rollouts -f values.yaml --namespace argo-rollouts --create-namespace

# add the client

```
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64

chmod +x ./kubectl-argo-rollouts-linux-amd64
sudo mv ./kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts

```

- then it will work the command

```

kubectl argo rollouts version
```

## to install the sample helm for the goapp

```
cd argo-rollouts/apps-helm/goapp

helm upgrade --install gapp8080 . -n staging -f values-staging.yaml
helm upgrade --install gapp80 . -n production -f values-production.yaml
```

## now in goapp-bluegreen converting the deployment to bluegreen argo rollouts

```
helm upgrade --install gapp . -n staging -f values.yaml
kubectl argo rollouts list rollouts -n staging
watch -n1 "kubectl argo rollouts get rollouts goapp80 -n staging"
k argo rollouts dashboard -p 3100
kubectl get all,rollouts,ep -n staging
```

## we need to upgrade only the image and with the above wathing what is happening with blue green
