
resource "azurerm_virtual_network" "linux-vnet" {
  name                = "${var.vnet_name}-${lower(var.environment)}"
  address_space       = ["10.180.0.0/16"]
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
}


resource "azurerm_subnet" "linux-subnet" {
  name                 = "${var.subnet_name}-${lower(var.environment)}"
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.linux-vnet.name
  address_prefixes     = ["10.180.2.0/24"]
}

