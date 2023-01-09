

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  count = var.aks_private_cluster == "true" ? 1 : 0
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.aks_dns_prefix
  kubernetes_version = var.aks_kubernetes_version
  # the name of the nodepool resource group if needs to be different RG
  node_resource_group = var.aks_node_resource_group
  # condition if the cluster is private or with external api access

  private_cluster_enabled = true
  private_dns_zone_id = azurerm_private_dns_zone.akszone[0].id
  
  # default system nodepool in separate network and separate only for system workloads related to kubernetes master nodes
  default_node_pool {
    name                 = "defaultpool"
    vm_size              = var.aks_default_pool_size 
    
    //availability_zones   = [1, 2, 3]
    enable_auto_scaling  = true
    max_count            = var.autoscaling_max_count
    min_count            = var.autoscaling_min_count
    os_disk_size_gb      = var.aks_os_disk_size_gb
    type                 = "VirtualMachineScaleSets"
    vnet_subnet_id       = var.aks_vnet_subnet_id
    node_labels = var.aks_node_labels
    only_critical_addons_enabled =true
  
  }


  # it works without this line but can be enabled in case of private cluster to depend on the role assignment for dns zone
  # depends_on = [
  #     azurerm_role_assignment.aksrole_zone,
  #   ]

  # can be used system assigned identity but it is used user assigned in this case
  # Identity (System Assigned or Service Principal)
  #   identity {
  #     type = "SystemAssigned"
  #   }

  #user assigned identity
  identity {
    type                      = "UserAssigned"
    identity_ids= [var.aks_user_assigned_identity]
  }


  # Add On Profiles for log analytics integration
  azure_policy_enabled = true
  oms_agent {
      
      log_analytics_workspace_id = var.aks_log_analytics_workspace
    }


  #uncomment this line and comment line below to enable directly integration with AD. It could be enabled later from GUI on aks
  # RBAC and Azure AD Integration Block
  role_based_access_control_enabled = true 
    
    azure_active_directory_role_based_access_control {
      managed                = true
      admin_group_object_ids = var.aks_rbac_ad_group_admin
      azure_rbac_enabled     = true
      # client_app_id = data.azurerm_key_vault_secret.sp-client-id.value
      # server_app_id = data.azurerm_key_vault_secret.sp-client-id.value
      # server_app_secret =  data.azurerm_key_vault_secret.sp-client-secret.value
    }

  #RBAC always should be enabled
  // role_based_access_control {
  //      enabled = true
  // }


  # Windows Profile for now we do not need it
  // windows_profile {
  //   admin_username = var.windows_admin_username
  //   admin_password = var.windows_admin_password
  // }

  # Linux Profile
  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      key_data = file("${path.cwd}/${var.aks-key}")
    }
  }

  # Network Profile
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

 tags = var.aks_tags
 lifecycle {
    ignore_changes = [
      tags,
      kubernetes_version,   
    ]
 }
 depends_on =[
    azurerm_private_dns_zone.akszone,
  
  ]
  
}

resource "azurerm_kubernetes_cluster" "aks_cluster_public" {
  count = var.aks_private_cluster == "false" ? 1 : 0
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.aks_dns_prefix
  kubernetes_version = var.aks_kubernetes_version
  # the name of the nodepool resource group if needs to be different RG
  node_resource_group = var.aks_node_resource_group
  # condition if the cluster is private or with external api access

  api_server_authorized_ip_ranges = var.aks_public_authorized_ranges
  
  # default system nodepool in separate network and separate only for system workloads related to kubernetes master nodes
  default_node_pool {
    name                 = "defaultpool"
    vm_size              = var.aks_default_pool_size 
   
   // availability_zones   = [1, 2, 3]
    enable_auto_scaling  = true
    max_count            = var.autoscaling_max_count
    min_count            = var.autoscaling_min_count
    os_disk_size_gb      = var.aks_os_disk_size_gb
    type                 = "VirtualMachineScaleSets"
    vnet_subnet_id       = var.aks_vnet_subnet_id
    node_labels = var.aks_node_labels
    only_critical_addons_enabled =true
   
    

  }


  # it works without this line but can be enabled in case of private cluster to depend on the role assignment for dns zone
  # depends_on = [
  #     azurerm_role_assignment.aksrole_zone,
  #   ]

  # can be used system assigned identity but it is used user assigned in this case
  # Identity (System Assigned or Service Principal)
  #   identity {
  #     type = "SystemAssigned"
  #   }

  #user assigned identity
  identity {
    type                      = "UserAssigned"
    identity_ids= [var.aks_user_assigned_identity]
  }


  # Add On Profiles for log analytics integration
  azure_policy_enabled = true
  oms_agent {
      
      log_analytics_workspace_id = var.aks_log_analytics_workspace
    }
 
    
  # keyvault_secrets_provider {

  #  secret_rotation_enabled =true
  #  secret_rotation_interval = '2m'
  # }
    
      
      
  


  #uncomment this line and comment line below to enable directly integration with AD. It could be enabled later from GUI on aks
  # RBAC and Azure AD Integration Block
  role_based_access_control_enabled = true 
    
    azure_active_directory_role_based_access_control {
      managed                = true
      admin_group_object_ids = var.aks_rbac_ad_group_admin
      azure_rbac_enabled     = true
      # client_app_id = data.azurerm_key_vault_secret.sp-client-id.value
      # server_app_id = data.azurerm_key_vault_secret.sp-client-id.value
      # server_app_secret =  data.azurerm_key_vault_secret.sp-client-secret.value
    }
 

  #RBAC always should be enabled
  // role_based_access_control {
  //      enabled = true
  // }


  # Windows Profile for now we do not need it
  // windows_profile {
  //   admin_username = var.windows_admin_username
  //   admin_password = var.windows_admin_password
  // }

  # Linux Profile
  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      key_data = file("${path.cwd}/${var.aks-key}")
    }
  }

  # Network Profile
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

 tags = var.aks_tags

 lifecycle {
    ignore_changes = [
      tags, 
      kubernetes_version,
      
    ]
 }
 depends_on =[
    azurerm_private_dns_zone.akszone,
    
  ]
  
}

