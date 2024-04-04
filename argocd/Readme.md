##Some installation steps from the documentation.

# to install argocd as from the documentation
https://argo-cd.readthedocs.io/en/stable/

`
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
`

#to install the plugin 

`git clone https://github.com/argoproj-labs/argocd-vault-plugin.git`
`git checkout tags/v1.13.1`  for particular tag matching to the release of the plugins
Then in manifests better to use the one with sidecar container (cmp-sidecar)
in kustomization.yaml file
`
   newTag: v2.5.4  needs to match the version of argocd 

   resources:
    - https://github.com/argoproj/argo-cd//manifests/cluster-install?ref=v2.5.4  # needs to match
    - cmp-plugin.yaml

   in argocd-repo-server.yaml
    env:
          - name: AVP_VERSION
            value: 1.13.1  ## the vault plugin verison from releases page
`
then with the command 
`
kubectl apply -k . -n argocd from inside the folder

`

for seled secrets
```
https://github.com/bitnami-labs/sealed-secrets/releases
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.26.2/kubeseal-0.26.2-linux-amd64.tar.gz
tar -xvf kubeseal-0.26.2-linux-amd64.tar.gz
sudo mv kubeseal /usr/local/bin
sudo chmod +x /usr/local/bin/kubeseal
```

Get the public key using
```
kubeseal --fetch-cert > publickey.pem
```
Encrypt the contents of the secret using the following command:

```
kubeseal --format=yaml --cert=publickey.pem < secret.yaml > sealedsecret.yaml
```
View the file contents:

cat sealedsecret.yaml