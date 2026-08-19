# goclaw-mcp-rbac.yaml

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: goclaw-k8s-viewer
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: goclaw-k8s-viewer-binding
subjects:
  - kind: ServiceAccount
    name: goclaw-k8s-viewer
    namespace: kube-system
roleRef:
  kind: ClusterRole
  name: view
  apiGroup: rbac.authorization.k8s.io
```

# Generate a long-lived token + kubeconfig for that ServiceAccount

Since Kubernetes 1.24+, SA tokens aren't auto-created — 
it needs explicitly via a Secret annotation (this gives you a non-expiring token, unlike kubectl create token which defaults to 1hr):
```yaml
# goclaw-mcp-token.yaml
apiVersion: v1
kind: Secret
metadata:
  name: goclaw-k8s-viewer-token
  namespace: kube-system
  annotations:
    kubernetes.io/service-account.name: goclaw-k8s-viewer
type: kubernetes.io/service-account-token
```
# apply the configuation 
```
kubectl apply -f goclaw-mcp-token.yaml
TOKEN=$(kubectl get secret goclaw-k8s-viewer-token -n kube-system -o jsonpath='{.data.token}' | base64 -d)
CA_CERT=$(kubectl get configmap kube-root-ca.crt -n kube-system -o jsonpath='{.data.ca\.crt}')
API_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
```

# build minimal scoped kubeconfig file 

```
kubectl config set-cluster goclaw-cluster --server="$API_SERVER" --certificate-authority=<(echo "$CA_CERT") \ 
   --embed-certs=true --kubeconfig=./kubeconfig
kubectl config set-credentials goclaw-k8s-viewer --token="$TOKEN" --kubeconfig=./kubeconfig
kubectl config set-context goclaw-k8s-viewer --cluster=goclaw-cluster --user=goclaw-k8s-viewer --kubeconfig=./kubeconfig
kubectl config use-context goclaw-k8s-viewer --kubeconfig=./kubeconfig
```

# Sanity-check it actually works and actually can't write

```
kubectl --kubeconfig=./kubeconfig get pods -A          # should work
kubectl --kubeconfig=./kubeconfig delete pod foo -n default  # should be forbidden

chmod 644 ./kubeconfig
```
