#This is the AKS identity aks uses as managed identity.Currently, an Azure Kubernetes Service (AKS) cluster (specifically,
# the Kubernetes cloud provider) requires an identity to create additional resources like load balancers and managed disks in Azure. 
#This identity can be either a managed identity or a service principal.
# Managing service principals adds complexity, which is why it's easier to use managed identities instead. 
# Managed identities are essentially a wrapper around service principals, and make their management simpler. Credential rotation for MI happens automatically every 46 days 
# according to Azure Active Directory default. AKS uses both system-assigned and user-assigned managed identity types. These identities are currently immutable. 

resource "azurerm_user_assigned_identity" "aks_identity" {
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  name                = var.aks-identity
   lifecycle {
    ignore_changes = [
      tags,   
    ]
 }
}

###it could be that the identity is created before the cluster
# data "azurerm_user_assigned_identity" "aks_identity" {
#   name                = var.aks-identity
#   resource_group_name = data.azurerm_resource_group.aks_rg.name
# }

# assigning contributor access to the managed identity from var.aks-identity
resource "azurerm_role_assignment" "vnet_contributor" {
  scope                = azurerm_virtual_network.aks_vnet.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}
