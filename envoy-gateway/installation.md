# install k3d

```
k3d cluster create envoy-cluster --api-port 6550 --servers 1 --agents 3 \
--k3s-arg "--disable=traefik@server:0" \
--k3s-arg "--disable=servicelb@server:0" --no-lb --wait
```

## install calico from documentation

```
k apply -f https://k3d.io/v5.0.0/usage/advanced/calico.yaml
```

## install metallb

```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml
```

# or install kind cluster

## kind-clu.yaml

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
```

kind create cluster --name envoy-cluster --config kind-cl.yaml

## for metallb after installation configure the pool

- install mettallb
  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml

- installing mettallb subnet but before check the docker network
  docker inspect k3d-envoy-cluster-server-0 | grep -i iprange

```
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
    - 172.20.8.1-172.20.8.254

```

or

```
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: ip-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.20.8.1-172.20.8.254 # replace with your output
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2advertisement
  namespace: metallb-system
spec:
  ipAddressPools:
  - ip-pool
---
```

- install envoy
  https://gateway.envoyproxy.io/v1.0.1/install/install-helm/

```

helm install eg oci://docker.io/envoyproxy/gateway-helm --version v1.1.0 \
              -n envoy-gateway-system --create-namespace  --set deployment.replicas=2

kubectl wait --timeout=5m -n envoy-gateway-system deployment/envoy-gateway --for=condition=Available


```
