#!/bin/bash

PROJECT="<project id>"
WORKLOAD_POOL="${PROJECT}.svc.id.goog"

args=(
--project "$PROJECT"
--no-enable-basic-auth
--cluster-version "1.25.6-gke.1000"
--release-channel "rapid"
--machine-type "e2-small"
--image-type "COS_CONTAINERD"
--disk-type "pd-balanced"
--disk-size "20"
--metadata disable-legacy-endpoints=true
--scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append"
--spot --num-nodes "1"
--logging=SYSTEM,WORKLOAD
--monitoring=SYSTEM
--enable-ip-alias
--network "projects/dev-k8s-367711/global/networks/default"
--subnetwork "projects/dev-k8s-367711/regions/europe-north1/subnetworks/default"
--no-enable-intra-node-visibility
--default-max-pods-per-node "110"
--enable-dataplane-v2
--no-enable-master-authorized-networks
--addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver
--enable-autoupgrade
--enable-autorepair
--max-surge-upgrade 1
--max-unavailable-upgrade 0
--workload-pool "$WORKLOAD_POOL"
--enable-shielded-nodes
--node-locations "europe-north1-a","europe-north1-b","europe-north1-c"
)
gcloud beta container clusters create "standard-public-cl1" --region europe-north1  "${args[@]}"