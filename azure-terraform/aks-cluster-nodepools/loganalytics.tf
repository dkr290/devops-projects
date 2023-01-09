# Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "aks-log-analytics" {
  name                = "aks-log-analytics-${lower(var.environment)}"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  retention_in_days   = 30

 lifecycle {
    ignore_changes = [
      tags,   
    ]
 }
  tags = local.common_tags
}

# in this case log analytics workspace is already created

// data "azurerm_log_analytics_workspace" "aks-log-analytics" {
//   name                = "dansadmin-aks-log-analytics1"
//   resource_group_name = data.azurerm_resource_group.aks_rg.name

// }
