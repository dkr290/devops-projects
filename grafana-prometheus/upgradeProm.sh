helm upgrade prometheus   prometheus-community/kube-prometheus-stack   --namespace prometheus   --set kubeEtcd.enabled=false   --set kubeControllerManager.enabled=false -f values.yaml 
