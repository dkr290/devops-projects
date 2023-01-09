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