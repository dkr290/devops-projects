resource "azurerm_user_assigned_identity" "aks_identity" {
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  name                = var.aks-identity
}

###it could be that the identity is created before the cluster
# data "azurerm_user_assigned_identity" "aks_identity" {
#   name                = var.aks-identity
#   resource_group_name = data.azurerm_resource_group.aks_rg.name
# }


resource "azurerm_role_assignment" "vnet_contributor" {
  scope                = azurerm_virtual_network.aks_vnet.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}
