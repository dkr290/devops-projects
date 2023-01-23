variable "subscription" {

  description = "subscription ID"
  type        = string

}

variable "location" {
  
  description = "Default location in azure"
  type        = string
}




variable "application" {
  default = "AKS"
}


variable "environment" {

  description = "Environment"
  type    = string

}

variable "aks-identity" {
  
  description = "Azure AKS managed Identity to be created or used"
  type        = string
}

variable "aks-resourcegroup" {
  
  type        = string
  description = "DEV,UAT,Production, QA aks RG name"
}

variable "kubernetes_version" {
  
  type        = string
  description = "fix the kubernetes version"
}

variable "aks-network-rg" {

  description = "The network resource group with the AKS vnet"
}

variable "environment_full" {
  description = "Full environment name "
}

variable "keyvault_name" {
  description = "Keyvault Name"
}


variable "aks-vnet" {

  description = " The vnet for AKS cluster"
}

variable "aks-subnet-1" {
  description = "The subnet in the vnet"
}









