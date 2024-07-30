kubectl create namespace argo
kubectl apply -n argo -f "https://github.com/argoproj/argo-workflows/releases/download/${ARGO_WORKFLOWS_VERSION}/quick-start-minimal.yaml"

EXAMPLE:
kubectl apply -n argo -f "https://github.com/argoproj/argo-workflows/releases/download/v3.5.9/quick-start-minimal.yaml

port forward
k -n argo port-forward deployments/argo-server 2746:2746

k patch deployment argo-server -n argo --type json --patch-file argo-server-patch.json
