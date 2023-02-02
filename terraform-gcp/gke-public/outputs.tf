output "cluster_endpoint" {
  description = "The IP address of the cluster master."
  sensitive   = true
  value       = module.gke_cluster.endpoint
}

output "client_certificate" {
  description = "Public certificate used by clients to authenticate to the cluster endpoint."
  value       = module.gke_cluster.client_certificate
}

output "client_key" {
  description = "Private key used by clients to authenticate to the cluster endpoint."
  sensitive   = true
  value       = module.gke_cluster.client_key
}

output "cluster_ca_certificate" {
  description = "The public certificate that is the root of trust for the cluster."
  sensitive   = true
  value       = module.gke_cluster.cluster_ca_certificate
}

output "gke_service_account" {
  value = module.gke_cluster.gke_service_account
}
output "gke_cluster_id" {
  value = module.gke_cluster.gke_cluster_id
  
}

output "gke_master_version" {
   value = module.gke_cluster.gke_master_version
}