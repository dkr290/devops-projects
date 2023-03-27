# Initialize gcloud CLI
gcloud init

# List accounts whose credentials are stored on the local system:
gcloud auth list

# List the properties in your active gcloud CLI configuration
gcloud config list

# View information about your gcloud CLI installation and the active configuration
gcloud info

# gcloud config Configurations Commands (For Reference)
```
gcloud config list
gcloud config configurations list
gcloud config configurations activate
gcloud config configurations create
gcloud config configurations delete
gcloud config configurations describe
gcloud config configurations rename
```

## Gcloud auth plugin


gke-gcloud-auth-plugin --version

# Install gke-gcloud-auth-plugin
gcloud components install gke-gcloud-auth-plugin

# Verify if gke-gcloud-auth-plugin installed
gke-gcloud-auth-plugin --version
## check kubectl
kubectl version --output=yaml


# List gcloud components
gcloud components list


# Install kubectl client
gcloud components install kubectl

# Verify kubectl version
kubectl version --output=yaml


# Verify kubeconfig file
kubectl config view

# Configure kubeconfig for kubectl 
gcloud container clusters get-credentials <GKE-CLUSTER-NAME> --region <REGION> --project <PROJECT>


# Verify kubeconfig file
kubectl config view

# Verify Kubernetes Worker Nodes
kubectl get nodes