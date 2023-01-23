


module "aks_cluster" {
  # the module name and folder
  source = "../modules/aks"
  # this is the aks name made from the variables
  aks_name =  "${var.aks_name_prefix}-${lower(var.environment)}"
  # This is the location
  location = data.azurerm_resource_group.aks_rg.location
  # This is the resource group name
  resource_group_name = data.azurerm_resource_group.aks_rg.name
  aks_dns_prefix = "${var.aks_name_prefix}-${lower(var.environment)}" #dns prefix 
  # the version is taken in this case dynamically like last stable version but can be assigned directly from variable
  #kubernetes_version = data.azurerm_kubernetes_service_versions.current.latest_version
  # in the case below it is static value
  aks_kubernetes_version = var.kubernetes_version
  # This is the node resource group in this case. This is created automatically and should not being pre-created.
  aks_node_resource_group = "${var.aks_name_prefix}-${lower(var.environment)}-pool" 
  #The default node pool. This is the system one for system pods like coredns etc. Small size is fine
  aks_default_pool_size = "Standard_B2s"
  #The autoscaling policy of the default (system) nodepool
  autoscaling_max_count = 4
  autoscaling_min_count = 2
  # The disk size for the worker nodes in this default nodepool
  aks_os_disk_size_gb  = 80
  # Is it private cluster boolean. In our case is always private
  aks_private_cluster = var.private_cluster
  # The dedicated subnet
  aks_vnet_subnet_id = data.azurerm_subnet.aks_subnet.id
  # The node labels 
  aks_node_labels = local.node_labels
  # Tags comming from local variables
  aks_tags = local.common_tags
  # The user assigned identity (managed identity) which is created with aks_identity.tf
  aks_user_assigned_identity = azurerm_user_assigned_identity.aks_identity.id
  # Participate to log analytics workspace
  aks_log_analytics_workspace = module.log-analytics.workspace_id
  # The active directory full admin group for AKS cluster
  aks_role_based_access_control = true
  aks_rbac_ad_group_admin = [data.azuread_group.aks_administrators.id]
  aks_aksrole_zone_principal_id = azurerm_user_assigned_identity.aks_identity.principal_id
  aks_azure_keyvault_secrets_provider=var.kv_secrets_csi_driver
  #The ssh public key needs to be used from the keyvault instead having it as a file
  aks-key       = data.azurerm_key_vault_secret.aks_ssh_public_key.value
  aks_private_dns_zone = var.private_dns_zone

 
  depends_on =[
    
    azurerm_user_assigned_identity.aks_identity,
    module.log-analytics,
    azurerm_private_dns_zone.akszone
  ]
}

module "log-analytics" {
  source = "../modules/log-analytics"
  aks-log-name = "aks-log-analytics-${lower(var.environment)}"
  aks-log-location = data.azurerm_resource_group.aks_rg.location
  aks-log-rg = data.azurerm_resource_group.aks_rg.name
  aks-log-sku = "PerGB2018" 
  aks-log-retention = 30
  
}


resource "azurerm_private_dns_zone" "akszone" {
  count = var.private_cluster == "true" ? 1 : 0
  name                = var.private_dns_zone
  resource_group_name = data.azurerm_resource_group.aks_rg.name
}
