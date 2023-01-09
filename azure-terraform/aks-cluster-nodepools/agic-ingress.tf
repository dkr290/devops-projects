
data "azurerm_user_assigned_identity" "ingress" {

  name                = "ingressapplicationgateway-${var.aks_name_prefix}-${lower(var.environment)}"
  resource_group_name = "${var.aks_name_prefix}-${lower(var.environment)}-nodepool"
  depends_on = [
    module.aks_cluster
  ]
}

resource "azurerm_role_assignment" "ra1" {
  
  scope                = azurerm_resource_group.aks_rg.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_user_assigned_identity.ingress.principal_id
}

resource "azurerm_role_assignment" "ra2" {
   
  scope                = azurerm_virtual_network.aks_vnet.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_user_assigned_identity.ingress.principal_id
}

resource "azurerm_role_assignment" "ra3" {
    
  scope                = azurerm_application_gateway.agic-ingress.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_user_assigned_identity.ingress.principal_id
}


resource "azurerm_public_ip" "agig-public-ip" {
    
  name                = "AGPUBIP"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  sku = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_application_gateway" "agic-ingress" {
    
  name                = "IngressAppGateway1"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }
gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.agic.id
  }
  frontend_ip_configuration {
    name                 = "appGatewayFrontendIP"
    public_ip_address_id = azurerm_public_ip.agig-public-ip.id
  }
  frontend_port {
    name = "appGatewayFrontendPort"
    port = 80
  }

backend_address_pool {
    name = "appGatewayBackendPool"
  }

    backend_http_settings {
    name                  = "appGatewayBackendHttpSettings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  http_listener {
    name                           = "appGatewayHttpListener"
    frontend_ip_configuration_name = "appGatewayFrontendIP"
    frontend_port_name             = "appGatewayFrontendPort"
    protocol                       = "Http"
  }

   request_routing_rule {
    name                       = "rule1"
    rule_type                  = "Basic"
    http_listener_name         = "appGatewayHttpListener"
    backend_address_pool_name  = "appGatewayBackendPool"
    backend_http_settings_name = "appGatewayBackendHttpSettings"
    priority = "1001"
  }

 lifecycle {
    ignore_changes = [
      request_routing_rule,
      probe,
      http_listener,
      backend_http_settings,
      tags,
      backend_address_pool,
      

    ]
 }


}

