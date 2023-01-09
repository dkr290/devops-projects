

# The aks rg in this case for exmaple aks-dev-rg
resource "azurerm_resource_group" "aks_rg" {
  name = var.aks-resourcegroup
  location = var.location

}


# get lateast aks version/ in this case this is not used because in the module we have fixed the version as best practice
# if you want to deploy latest version and then change the line in the module aks.tf section.
data "azurerm_kubernetes_service_versions" "current" {
  location        = azurerm_resource_group.aks_rg.location
  include_preview = false
}


# the actual vnet for AKS vnet-dev-k8s-neu
resource "azurerm_virtual_network" "aks_vnet" {
  name                = var.aks-vnet
  location = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  address_space = [ "10.152.0.0/16" ]
}

# The actual subnet depends on the cluster for astronomer it is called aks-cluster-dev (or aks-astronomer-dev)
# for bankingcircle AKS it is called (aks-bc-dev)
resource "azurerm_subnet" "aks_subnet" {
  name                 = var.aks-subnet-1
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes = ["10.152.72.0/21"]



}

resource "azurerm_subnet" "agic" {
  name                 = var.aks-agic
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes = ["10.152.80.0/24"]



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


# very important for RBAC. This is the AD group, the members of will have always AKS admin access 
data "azuread_group" "aks_administrators" {
  display_name = var.aks_administrators

}


## is we need different nodepool and subnet

// data "azurerm_subnet" "aks_subnet_nodepool" {
//   name                 = "dansadmin-aks2-dev"
//   resource_group_name = data.azurerm_resource_group.aks_network_rg.name
//   virtual_network_name = data.azurerm_virtual_network.aks_vnet.name



// }
