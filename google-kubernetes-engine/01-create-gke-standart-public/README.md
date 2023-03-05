---
title: GCP Google Kubernetes Engine - Create GKE Cluster
---

## 01: Introduction
- Create GKE Standard GKE Cluster 
- Configure Google CloudShell to access GKE Cluster
- Deploy simple Kubernetes Deployment and Kubernetes Load Balancer Service and Test 
- Clean-Up

## 02: Create Standard GKE Cluster 
- Go to Kubernetes Engine -> Clusters -> CREATE
- Select **GKE Standard -> CONFIGURE**
- **Cluster Basics**
  - **Name:** standard-public-cl1
  - **Location type:** Regional
  - **Region:** europe-north11
  - **Specify default node locations:** europe-north1-a, europe-north1-b, europe-north1-c
  - **Release Channel**
    - **Release Channel:** Rapid Channel
    - **Version:** LATEST AVAIALABLE ON THAT DAY
  - REST ALL LEAVE TO DEFAULTS
- **NODE POOLS: default-pool**
- **Node pool details**
  - **Name:** default-pool
  - **Number of Nodes (per zone):** 1
  - **Node Pool Upgrade Strategy:** Surge Upgrade
- **Nodes: Configure node settings** 
  - **Image type:** Containerized Optimized OS
  - **Machine configuration**
    - **GENERAL PURPOSE SERIES:** E2
    - **Machine Type:** e2-small
  - **Boot disk type:** Balanced persistent disk
  - **Boot disk size(GB):** 20
  - **Boot disk encryption:** Google-managed encryption key (default )
  - **Enable Node on Spot VMs:** CHECKED
- **Node Networking:** default  
- **Node Security:** 
  - **Access scopes:** Allow default access (LEAVE TO DEFAULT)
  - REST ALL default
- **Node Metadata:** default
- **CLUSTER** 
  - **Automation:** default
  - **Networking:** default
    - **CHECK THIS BOX: Enable Dataplane V2** check it it will be defaul,t in the future
  - **Security:** default
    - **CHECK THIS BOX: Enable Workload Identity** check it
  - **Metadata:** default
  - **Features:** default
- CLICK ON **CREATE**

## 03: Verify Cluster Details
- Go to Kubernetes Engine -> Clusters 
- Review
  - Details Tab
  - Nodes Tab
    - Review same nodes **Compute Engine**
  - Storage Tab
    - Review Storage Classes
  - Logs Tab
    - Review Cluster Logs
    - Review Cluster Logs **Filter By Severity**

- Go to Kubernetes Engine -> Clusters 
- Workloads -> **SHOW SYSTEM WORKLOADS**

### 04: Verify Services & Ingress
- Go to Kubernetes Engine -> Clusters 
- Services & Ingress -> **SHOW SYSTEM OBJECTS**

### 05: Verify Applications, Secrets & ConfigMaps
- Go to Kubernetes Engine -> Clusters 
- Applications
- Secrets & ConfigMaps

### 06: Verify Storage
- Go to Kubernetes Engine -> Clusters
- Storage Classes
  - premium-rwo
  - standard
  - standard-rwo

### 07: Verify the below
1. Object Browser
2. Migrate to Containers
3. Backup for GKE
4. Config Management
5. Protect

## 08: Connect to GKE Cluster using kubectl (in cloued shell)
- [kubectl Authentication in GKE](https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke)
```t
# Verify gke-gcloud-auth-plugin Installation (if not installed, install it)
gke-gcloud-auth-plugin --version 

# Install Kubectl authentication plugin for GKE
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin

# Verify gke-gcloud-auth-plugin Installation
gke-gcloud-auth-plugin --version 

# Configure kubeconfig for kubectl
gcloud container clusters get-credentials <CLUSTER-NAME> --region <REGION> --project <PROJECT-NAME>



## Step-09: Deploy Sample Application and Verify
```

# Deploy Sample App using kubectl
kubectl apply -f kube-manifests/

# List Deployments
kubectl get deploy

# List Pods
kubectl get pod

# List Services
kubectl get svc

# Access Sample Application
http://<EXTERNAL-IP>
```

## Step-10: Verify Workloads in GKE Dashboard
- Go to GCP Console -> Kubernetes Engine -> Workloads
- Click on  **httpd-deployment**
- Review all tabs

## Step-11: Verify Services in GKE Dashboard
- Go to GCP Console -> Kubernetes Engine -> Services & Ingress
- Click on **myapp1-lb-service**
- Review all tabs

## Step-13: Verify Load Balancer
- Go to GCP Console -> Networking Services -> Load Balancing
- Review all tabs

## Step-14: Clean-Up
- Go to Google Cloud Shell
```t

# Delete Kubernetes Deployment and Service
kubectl delete -f kube-manifests/

# List Deployments
kubectl get deploy

# List Pods
kubectl get pod

# List Services
kubectl get svc

# delete the cluster
gcloud container clusters list --region=europe-north1
gcloud container clusters delete <clustername>  --region=europe-north1
```


