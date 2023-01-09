
# This is the actual module all the module logic is store in subfolder aks

module "aks_cluster" {
  # modeule name and folder
  source = "./aks"
  #This is the aks name made from variables 
  aks_name =  "${var.aks_name_prefix}-${lower(var.environment)}"
  # This is location like northeurope or westeurope
  location = azurerm_resource_group.aks_rg.location
  # This is the resource group like aks-dev-rg etc.
  resource_group_name = azurerm_resource_group.aks_rg.name
  # The preffix needed
  aks_dns_prefix = "${var.aks_name_prefix}-${lower(var.environment)}" #dns prefix 
  # the version is taken in this case dynamically like last stable version but can be assigned directly from variable
  #kubernetes_version = data.azurerm_kubernetes_service_versions.current.latest_version
  # in the case below it is static value
  aks_kubernetes_version = var.kubernetes_version
  # This is the node resource group in this case is for example aks-astronomer${env}-nodepool. This is created automatically and should not being pre-created.
  aks_node_resource_group = "${var.aks_name_prefix}-${lower(var.environment)}-nodepool" 
  #The default node pool. This is the system one for system pods like coredns etc. Small size is fine
  aks_default_pool_size = "Standard_B2s"
  #The autoscaling policy of the default (system) nodepool
  autoscaling_max_count = 4
  autoscaling_min_count = 2
  # The disk size for the worker nodes in this default nodepool
  aks_os_disk_size_gb  = 30
  #Is it private cluster boolean. In our case is always private
  aks_private_cluster = var.private_cluster
  # The dedicated subent
  aks_vnet_subnet_id = azurerm_subnet.aks_subnet.id
  # The labels of the nodes
  aks_node_labels = local.node_labels
  # Tags comming from local variables
  aks_tags = local.common_tags
  # The user assigned identity (managed identity) which is created with aks_identity.tf
  aks_user_assigned_identity = azurerm_user_assigned_identity.aks_identity.id
  # Participate to log analytics workspace
  aks_log_analytics_workspace = azurerm_log_analytics_workspace.aks-log-analytics.id
  # Enable RBAC in this case yes and by AD group
  aks_role_based_access_control = true
  # The active directory full admin group for AKS cluster
  aks_rbac_ad_group_admin = [data.azuread_group.aks_administrators.id]
  aks_aksrole_zone_principal_id = azurerm_user_assigned_identity.aks_identity.principal_id
  # The csi driver to be enabled 
  aks_azure_keyvault_secrets_provider=var.kv_secrets_csi_driver
  # What kind of nodepools to create in addition to the default one
  aks_node_pools = local.node_pools
  aks_private_dns_zone = var.private_dns_zone
  aks_public_authorized_ranges= var.public_autohorized_ranges

  ##if application gateway is enaled
  aks_agic_id = azurerm_application_gateway.agic-ingress.id
 
  
  

 
  depends_on =[
    
    azurerm_user_assigned_identity.aks_identity,
    
  ]
}
