output "name" {

  description = "The name of the cluster master. This output is used for interpolation with node pools, other modules."
  value = google_container_cluster.cluster.name
}

output "master_version" {
  description = "The Kubernetes master version."
  value       = google_container_cluster.cluster.master_version
}

output "endpoint" {
  description = "The IP address of the cluster master."
  sensitive   = true
  value       = google_container_cluster.cluster.endpoint
}

# The following outputs allow authentication and connectivity to the GKE Cluster.
output "client_certificate" {
  description = "Public certificate used by clients to authenticate to the cluster endpoint."
  value       = base64decode(google_container_cluster.cluster.master_auth[0].client_certificate)
}

output "client_key" {
  description = "Private key used by clients to authenticate to the cluster endpoint."
  value       = base64decode(google_container_cluster.cluster.master_auth[0].client_key)
}

output "cluster_ca_certificate" {
  description = "The public certificate that is the root of trust for the cluster."
  value       = base64decode(google_container_cluster.cluster.master_auth[0].cluster_ca_certificate)
}

output "gke_service_account" {
  description = "The service account used" 
  value = google_service_account.svc-gke.email
  
}

output "gke_cluster_id" {
   description = "The id of the cluster"
   value = google_container_cluster.cluster.id
  
}

output "gke_master_version" {
  description = "The current version of the master in the cluster. This may be different than the min_master_version set in the config if the master has been updated by GKE."
  value = google_container_cluster.cluster.master_version
}