# goclaw-mcp-rbac.yaml

The built-in `view` ClusterRole is **not enough** for the kubernetes-mcp
observer agent. It is missing the node-level and cluster-scoped read
permissions that several MCP skills need:

| MCP skill | Required permission | In built-in `view`? |
|---|---|---|
| `k8s_nodes_top` | `nodes.metrics.k8s.io` | ✅ yes |
| `k8s_nodes_log` | `nodes/proxy` | ❌ **no** |
| `k8s_nodes_stats_summary` | `nodes/stats` | ❌ **no** |
| `k8s_resources_get` / `k8s_resources_list` on cluster-scoped kinds | `nodes`, `persistentvolumes`, `storageclasses`, `ingressclasses`, `clusterroles`, `clusterrolebindings`, `customresourcedefinitions` | ❌ **no** |
| Cilium observability | `ciliumnetworkpolicies`, `ciliumclusterwidenetworkpolicies`, `ciliumendpoints`, `ciliumidentities`, `ciliumnodes` | ❌ **no** |
| Gateway API / Envoy Gateway | `gateways`, `gatewayclasses`, `httproutes`, `tcproutes`, `tlsroutes`, `udproutes`, `grpcroutes`, `referencegrants`, plus `gateway.envoyproxy.io` policy CRDs | ❌ **no** |

A **ready-to-apply** manifest with an extended ClusterRole
(`goclaw-k8s-observer` = everything `view` has + the missing node,
cluster-scoped, Cilium, and Gateway API reads, still 100% read-only)
lives in
[`roles-examples/goclaw-mcp-rbac.yaml`](roles-examples/goclaw-mcp-rbac.yaml).

Apply it:

```bash
kubectl apply -f roles-examples/goclaw-mcp-rbac.yaml
```

That single file creates:
- `ServiceAccount/goclaw-k8s-viewer` (namespace `kube-system`)
- `ClusterRole/goclaw-k8s-observer` (extended read-only)
- `ClusterRoleBinding/goclaw-k8s-viewer-binding`
- `Secret/goclaw-k8s-viewer-token` (long-lived SA token, K8s ≥ 1.24)

# Generate a long-lived token + kubeconfig for that ServiceAccount

The token Secret is already created by the manifest above (no separate
`goclaw-mcp-token.yaml` needed). Extract the credentials:

```
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
kubectl --kubeconfig=./kubeconfig get nodes            # should work (extended role)
kubectl --kubeconfig=./kubeconfig get --raw /api/v1/nodes/<node-name>/proxy/stats/summary | head -c 200   # should work (k8s_nodes_stats_summary)
kubectl --kubeconfig=./kubeconfig get ciliumnetworkpolicies -A   # should work (Cilium)
kubectl --kubeconfig=./kubeconfig get gateways,httproutes -A      # should work (Gateway API)
kubectl --kubeconfig=./kubeconfig delete pod foo -n default  # should be forbidden

chmod 644 ./kubeconfig
```

# Change the Kubeconfig server to the loadbalancer like:
```
    docker ps #inspect which server maps the port
    https://k3d-eg-operator-serverlb:6443
```
