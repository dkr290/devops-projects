


data "azurerm_resource_group" "aks_rg" {
  name = var.aks-resourcegroup

}

data "azurerm_resource_group" "aks_network_rg" {
  name = var.aks-network-rg
}
# get lateast aks version
data "azurerm_kubernetes_service_versions" "current" {
  location        = data.azurerm_resource_group.aks_rg.location
  include_preview = false
}

data "azurerm_virtual_network" "aks_vnet" {
  name                = var.aks-vnet
  resource_group_name = data.azurerm_resource_group.aks_network_rg.name
}
data "azurerm_subnet" "aks_subnet" {
  name                 = var.aks-subnet-1
  resource_group_name  = data.azurerm_resource_group.aks_network_rg.name
  virtual_network_name = data.azurerm_virtual_network.aks_vnet.name



}


data "azurerm_key_vault" "key-vault" {
  name                = var.keyvault_name
  resource_group_name = data.azurerm_resource_group.aks_rg.name
}

data "azurerm_key_vault_secret" "aks_ssh_public_key" {
  name         = var.ssh_key_vault_secret
  key_vault_id = data.azurerm_key_vault.key-vault.id
}

resource "azurerm_monitor_diagnostic_setting" "aks-diagnostics" {
  name                       = "aks-log-analytics-${lower(var.environment)}-diagnostics"
  target_resource_id         = module.aks_cluster.aks_cluster_id
  log_analytics_workspace_id = module.log-analytics.workspace_id

  log {
    category = "kube-apiserver"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }
  log {
    category = "kube-audit"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }
  log {
    category = "kube-audit-admin"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "kube-controller-manager"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }
  log {
    category = "kube-scheduler"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }
  log {
    category = "csi-snapshot-controller"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "cluster-autoscaler"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }
  log {
    category = "cloud-controller-manager"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }
  log {
    category = "guard"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }
  log {
    category = "csi-azuredisk-controller"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "csi-azurefile-controller"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }


  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days    = 90
    }
  }
}




data "azuread_group" "aks_administrators" {
  display_name = var.aks_administrators

}


