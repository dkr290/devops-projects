


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

