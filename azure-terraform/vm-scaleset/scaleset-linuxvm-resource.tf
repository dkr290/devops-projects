# Locals Block for custom data
locals {
webvm_custom_data = <<CUSTOM_DATA
#!/bin/bash
sudo apt-get update && apt-get -y upgrade
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common ca-certificates gnupg
 
CUSTOM_DATA
}



resource "azurerm_linux_virtual_machine_scale_set" "build-linuxvm" {
  name                      = "${var.deployment_prefix}-vmss"
  resource_group_name = data.azurerm_resource_group.rg.name
  location = data.azurerm_resource_group.rg.location 
  sku                       = "Standard_F4s_v2"
  instances                 = var.numberOfWorkerNodes

  overprovision             = false
  single_placement_group    = false

  admin_username            = "adminuser"
  disable_password_authentication = false
  admin_password            = "xxxxxxx"
 


  source_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-focal"
    sku = "20_04-lts-gen2"
    version = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadOnly"
    disk_size_gb         = "64"

    diff_disk_settings {
      option = "Local"
    }
  }

  network_interface {
    name    = "${var.deployment_prefix}-vmss-nic"
    primary = true

    ip_configuration {
      name      = "${var.deployment_prefix}-vmss-ipconfig"
      primary   = true
      subnet_id = data.azurerm_subnet.subnet.id
    }
  }

  boot_diagnostics {
    storage_account_uri = null
  }

  lifecycle {
    ignore_changes = [
      extension,
      tags,
      automatic_instance_repair,
      automatic_os_upgrade_policy,
      instances,
    ]
  }
  custom_data = base64encode(local.webvm_custom_data)
  tags = local.common_tags
}


