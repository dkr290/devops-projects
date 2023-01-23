variable "aks-resourcegroup" {
    description = "The Resourcce group name"
    type = string
  
}

variable "private_dns_zone" {
    description = "The name of the zone"

  
}

variable "subscription" {

  description = "subscription ID"
  type        = string

}

variable "location" {
  
  description = "Default location in azure"
  type        = string
}
variable "application" {
  descdescription = "Application name" 
}


variable "environment" {

  description = "Short environment name"
  type    = string

}

variable "environment_full" {
  description = "Full environment name"
}

variable "virtual_network_link" {
  
}


variable "aks-vnet" {
  
}
