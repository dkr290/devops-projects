variable "network_resource_group_name" {
  default     = "network-dev-rg"
  description = "Name of resource group where vnet and subnets are placed"
}

variable "vnet_name" {
  default     = "vnet-dev"
  description = "VNET to deploy scaleset in"
}

variable "subnet_name" {
  default     = "common-lnxvmss-dev"
  description = "Subnet inside of VNET to deploy scaleset in"
}
