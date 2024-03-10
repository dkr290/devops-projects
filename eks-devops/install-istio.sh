helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
helm install istio-base istio/base -n istio-system --set defaultRevision=default --create-namespace
helm upgrade --install istiod istio/istiod -n istio-system --set global.defaultPodDisruptionBudget.enabled=false


helm install istio-ingressgateway istio/gateway -n istio-ingress --create-namespace
helm install istio-egressgateway istio/gateway --set service.type=ClusterIP -n istio-ingress