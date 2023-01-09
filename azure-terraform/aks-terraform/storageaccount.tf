# resource "azurerm_storage_account" "aks_storage" {
#   name                = "aksastrorepo${lower(var.environment)}"
#   resource_group_name = data.azurerm_resource_group.aks_rg.name

#   location                 = data.azurerm_resource_group.aks_rg.location
#   account_tier             = "Standard"
#   account_replication_type = "GRS"
#   allow_blob_public_access = false

#   network_rules {
#     default_action             = "Allow"
#     ip_rules                   = ["x.x.x.x/30"]
#     virtual_network_subnet_ids = [data.azurerm_subnet.aks_subnet.id]
#   }

#   tags = local.common_tags
#   lifecycle {
#     ignore_changes = [
#       tags,   
#     ]
#   }
# }