k3d cluster create envoy-cluster --api-port 6550 --servers 1 --agents 3 \
--k3s-arg "--disable=traefik@server:0" \
--k3s-arg "--disable=servicelb@server:0" --no-lb --wait

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
