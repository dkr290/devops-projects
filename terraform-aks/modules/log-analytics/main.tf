resource "azurerm_log_analytics_workspace" "aks-log-analytics" {
  name                = var.aks-log-name
  location            = var.aks-log-location
  resource_group_name = var.aks-log-rg
  sku                 = var.aks-log-sku
  retention_in_days   =  var.aks-log-retention
  lifecycle {
    ignore_changes = [
      tags,   
    ]
 }
}