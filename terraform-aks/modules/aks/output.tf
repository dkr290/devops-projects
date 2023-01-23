output "location" {
  value = var.aks_private_cluster == "true" ? azurerm_kubernetes_cluster.aks_cluster[0].location : azurerm_kubernetes_cluster.aks_cluster_public[0].location
}

output "resource_group" {
  value = var.aks_private_cluster == "true" ? azurerm_kubernetes_cluster.aks_cluster[0].resource_group_name : azurerm_kubernetes_cluster.aks_cluster_public[0].resource_group_name
}


output "node_resource_group" {
    value = var.aks_private_cluster == "true" ? azurerm_kubernetes_cluster.aks_cluster[0].node_resource_group : azurerm_kubernetes_cluster.aks_cluster_public[0].node_resource_group
}

output "versions" {
  value = var.aks_private_cluster == "true" ? azurerm_kubernetes_cluster.aks_cluster[0].kubernetes_version : azurerm_kubernetes_cluster.aks_cluster_public[0].kubernetes_version
}


output "aks_cluster_name" {
  value = var.aks_private_cluster == "true" ? azurerm_kubernetes_cluster.aks_cluster[0].name : azurerm_kubernetes_cluster.aks_cluster_public[0].name
}

output "aks_cluster_id" {
  value = var.aks_private_cluster == "true" ? azurerm_kubernetes_cluster.aks_cluster[0].id : azurerm_kubernetes_cluster.aks_cluster_public[0].id
}
