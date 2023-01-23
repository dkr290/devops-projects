resource "azurerm_kubernetes_cluster_node_pool" "aks_nodepool" {
 for_each = local.aks_node_pools 
  availability_zones    = [1, 2, 3]
  enable_auto_scaling   = true
  kubernetes_cluster_id = data.terraform_remote_state.bc-aks.outputs.cluster_id
  min_count             = each.value.min_nodes
  max_count             = each.value.max_nodes
  mode                  = "User"
  name                  =  each.value.name
  orchestrator_version  = each.value.k_version
  os_disk_size_gb       = each.value.os_disk_size
  os_type               = "Linux" # Default is Linux, we can change to Windows
   vm_size               = each.value.vm_size
   priority              = "Regular"  # Default is Regular, we can change to Spot with additional settings like eviction_policy, spot_max_price, node_labels and node_taints
  vnet_subnet_id        = data.azurerm_subnet.aks_subnet.id #optional we can force this nodepool to go to another dedicated network
  node_labels = each.value.node_labels
  tags = local.common_tags
  node_taints =  lookup(each.value, "node_taints", null)

  
 lifecycle {
    ignore_changes = [
      tags, 
      
        
    ]
 }
  
}