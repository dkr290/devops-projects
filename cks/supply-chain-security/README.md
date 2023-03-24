## how to install in int k8s

https://kubernetes.io/blog/2019/08/06/opa-gatekeeper-policy-and-governance-for-kubernetes/


https://open-policy-agent.github.io/gatekeeper/website/docs/install/

kubectl get constrainttemplate,constraint
kubectl get constrainttemplate -o yaml k8simagewhitelist
kubectl get constraint -o yaml k8senforcewhitelistedimages

k get constrainttemplates
k get k8swhitelistedimages

k describe constraint k8senforcewhitelistedimages