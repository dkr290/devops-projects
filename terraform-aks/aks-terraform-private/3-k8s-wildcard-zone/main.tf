
data "azurerm_virtual_network" "aks_vnet" {
  name                = var.aks-vnet
  resource_group_name = var.aks-resourcegroup
}

resource "azurerm_private_dns_zone" "k8s-zone" {
  name                = var.private_dns_zone
  resource_group_name = var.aks-resourcegroup
  tags = local.common_tags


 lifecycle {
    ignore_changes = [
      tags,   
    ]
 }
  
}

resource "azurerm_private_dns_zone_virtual_network_link" "aks-vnet" {
  name                  = var.virtual_network_link
  resource_group_name   = azurerm_private_dns_zone.k8s-zone.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.k8s-zone.name
  virtual_network_id    = data.azurerm_virtual_network.aks_vnet.id
}



resource "azurerm_private_dns_a_record" "k8s-zone-records" {
  for_each = local.records
  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.k8s-zone.name
  resource_group_name = azurerm_private_dns_zone.k8s-zone.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records

  depends_on = [
    azurerm_private_dns_zone.k8s-zone
  ]
}