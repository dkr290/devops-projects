variable "network_resource_group_name" {
  default     = "network-test-rg"
  description = "Name of resource group where vnet and subnets are placed"
}

variable "vnet_name" {
  default     = "linux-vnet"
  description = "VNET to deploy scaleset in"
}

variable "subnet_name" {
  default     = "linux-subnet"
  description = "Subnet inside of VNET to deploy scaleset in"
}
