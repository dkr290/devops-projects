
output "cluster_id" {
  value = module.aks_cluster.aks_cluster_id
}

output "workspace_id" {
  value = module.log-analytics.workspace_id
}