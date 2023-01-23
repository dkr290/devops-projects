resource "azurerm_user_assigned_identity" "aks_identity" {
  resource_group_name = data.azurerm_resource_group.aks_rg.name
  location            = data.azurerm_resource_group.aks_rg.location
  name                = var.aks-identity
   lifecycle {
    ignore_changes = [
      tags,   
    ]
 }
}



resource "azurerm_role_assignment" "vnet_contributor" {
  scope                = data.azurerm_virtual_network.aks_vnet.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}
