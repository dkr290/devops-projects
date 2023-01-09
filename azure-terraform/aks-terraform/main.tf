


resource "azurerm_resource_group" "aks_rg" {
  name = var.aks-resourcegroup
  location = var.location

}

resource "azurerm_resource_group" "aks_network_rg" {
  name = var.aks-network-rg
  location = var.location
}
# get lateast aks version
data "azurerm_kubernetes_service_versions" "current" {
  location        = azurerm_resource_group.aks_rg.location
  include_preview = false
}



resource "azurerm_virtual_network" "aks_vnet" {
  name                = var.aks-vnet
  resource_group_name = azurerm_resource_group.aks_network_rg.name
  location = var.location
  address_space = ["10.180.0.0/16"]
}
resource "azurerm_subnet" "aks_subnet" {
  name = var.aks-subnet-1
  address_prefixes      = ["10.180.0.0/20"]
  resource_group_name = azurerm_resource_group.aks_network_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
 



}
## get SP credentials
// data "azurerm_key_vault" "aks_keyvault"{

//   name = var.keyvault_name
//   resource_group_name = data.azurerm_resource_group.aks_rg.name
// }

// data "azurerm_key_vault_secret" "sp-client-id" {
//   name         = "sp-client-id"
//   key_vault_id = data.azurerm_key_vault.aks_keyvault.id
// }

// data "azurerm_key_vault_secret" "sp-client-secret" {
//   name         = "sp-client-secret"
//   key_vault_id = data.azurerm_key_vault.aks_keyvault.id
// }

data "azuread_group" "aks_administrators" {
  display_name = "k8sadmins"

}


## is we need different nodepool and subnet

// data "azurerm_subnet" "aks_subnet_nodepool" {
//   name                 = "admin-aks2-dev"
//   resource_group_name = data.azurerm_resource_group.aks_network_rg.name
//   virtual_network_name = data.azurerm_virtual_network.aks_vnet.name



// }
