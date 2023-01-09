
# resource "azurerm_storage_account" "velero_storage_account" {
  
#   name                = "storageaccount80${lower(var.environment)}"
#   resource_group_name = data.azurerm_resource_group.aks_rg.name

#   location                 = data.azurerm_resource_group.aks_rg.location
#   account_tier             = "Standard"
#   account_replication_type = "GRS"
#   allow_blob_public_access = true


#   tags = local.common_tags
#   lifecycle {
#     ignore_changes = [
#       tags,   
#     ]
#   }
# }