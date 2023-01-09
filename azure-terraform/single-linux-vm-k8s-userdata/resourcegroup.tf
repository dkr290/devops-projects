resource "azurerm_resource_group" "rg" {
  name = var.resource_group_name
  location = var.resource_group_location
 
}

resource "azurerm_resource_group" "network_rg" {
  name = var.network_resource_group_name
  location = var.resource_group_location
 
}


