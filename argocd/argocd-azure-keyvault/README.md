# Introduction 
This is a repo that will describe how argoCD has to be deployed with all azure plugins. 

# Getting Started

1.	Installation process

NOTE:
always check the official repo from the installation of the plugin if something gets changed
https://argocd-vault-plugin.readthedocs.io/en/stable/installation/
for sidecar stuff
* First change the latest stable version to the file kustomization.yaml - newTag: v2.6.1 and in the resources
* Second check the file argocd-repo-server.yaml and see which is the latest plugin verion
```
    env:
          - name: AVP_VERSION
            value: 1.13.1
```

2.	If you are upgrading not initial installing export argocd-cm and argocd-rbac-cm
```
kubectl get cm argocd-cm -o yaml > argocd-cm.yml

```

```
kubectl get cm argocd-rbac-cm -o yaml > argocd-rbac-cm.yml

```

The file might be the same as in the repo thoose are files from previous upgrade. The idea is that if we want to be integrated with Azure AD thoose files gets overriten by upgrade.

same is for the secret
```
kubectl get secret argocd-secret -o yaml > argocd-secret.yaml
```
3.	Upgrade or install

Inside the directory 
```
kubectl -k . -n argocd
#then remove and apply all the files

kubectl delete -f argocd-cm.yaml -n argocd
kubectl apply -f argocd-cm.yaml -n argocd
kubectl delete -f argocd-rbac-cm.yaml -n argocd
kubectl apply -f argocd-rbac-cm.yaml -n argocd

```

for the secret file you can override it but better to do 
```
kubectl edit argocd-secret -n argocd ##and see if it contains  oidc.azure.clientSecret:

##if not add it from the previous installation

```


//TODO automate this with kustomize