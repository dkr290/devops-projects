
 
 
 resource "azurerm_kubernetes_cluster_node_pool" "aks_nodepool" {
 for_each = var.aks_node_pools 
   #availability_zones    = [1, 2, 3]
  enable_auto_scaling   = true
  kubernetes_cluster_id = var.aks_private_cluster == "false" ? azurerm_kubernetes_cluster.aks_cluster_public[0].id : azurerm_kubernetes_cluster.aks_cluster[0].id
  max_count             = each.value.max_nodes
  min_count             = each.value.min_nodes
  mode                  = "User"
  name                  =  each.value.name
  orchestrator_version  = each.value.kubernetes_version
  os_disk_size_gb       = each.value.os_disk_size
  os_type               = "Linux" # Default is Linux, we can change to Windows
   vm_size               = each.value.vm_size
   priority              = "Regular"  # Default is Regular, we can change to Spot with additional settings like eviction_policy, spot_max_price, node_labels and node_taints
  vnet_subnet_id        = var.aks_vnet_subnet_id #optional we can force this nodepool to go to another dedicated network
  node_labels = each.value.node_labels
  tags = var.aks_tags
  node_taints =  lookup(each.value, "node_taints", null)

  
 lifecycle {
    ignore_changes = [
      tags,   
    ]
 }
  
}





 
