


module "aks_cluster" {
  source = "./aks"
  aks_name =  "${var.aks_name_prefix}-${lower(var.environment)}"
  location = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  aks_dns_prefix = "aks-cluster-${lower(var.environment)}" #dns prefix 
  # the version is taken in this case dynamically like last stable version but can be assigned directly from variable
  #kubernetes_version = data.azurerm_kubernetes_service_versions.current.latest_version
  # in the case below it is static value
  aks_kubernetes_version = var.kubernetes_version
  aks_node_resource_group = "${azurerm_resource_group.aks_rg.name}-nodepool" 
  aks_default_pool_size = "Standard_B2s"
  autoscaling_max_count = 2
  autoscaling_min_count = 1
  aks_os_disk_size_gb  = 30
  aks_private_cluster = var.private_cluster
  aks_vnet_subnet_id = azurerm_subnet.aks_subnet.id
  aks_node_labels = local.default_nodepool_node_labels
  aks_tags = local.common_tags
  aks_user_assigned_identity = azurerm_user_assigned_identity.aks_identity.id
  aks_log_analytics_workspace = azurerm_log_analytics_workspace.aks-log-analytics.id
  aks_role_based_access_control = true
  aks_rbac_ad_group_admin = [data.azuread_group.aks_administrators.id]
  aks_aksrole_zone_principal_id = azurerm_user_assigned_identity.aks_identity.principal_id
  aks_public_authorized_ranges = var.public_authorized_ranges
  aks_azure_keyvault_secrets_provider=var.kv_secrets_csi_driver
  aks_node_pools = local.node_pools

 
  depends_on =[
    
    azurerm_user_assigned_identity.aks_identity
  ]
}
