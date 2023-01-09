resource "azurerm_private_dns_zone" "akszone" {
  count = var.aks_private_cluster == "true" ? 1 : 0
  name                = "privatelink.northeurope.azmk8s.io"
  resource_group_name = var.resource_group_name
  lifecycle {
    ignore_changes = [
      tags,   
    ]
 }
}

resource "azurerm_role_assignment" "aksrole_zone" {
  count = var.aks_private_cluster == "true" ? 1 : 0
  scope                = azurerm_private_dns_zone.akszone[0].id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = var.aks_aksrole_zone_principal_id
}
