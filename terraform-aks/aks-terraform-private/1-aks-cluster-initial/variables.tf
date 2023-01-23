variable "subscription" {

  description = "Subscription ID"
  type        = string

}

variable "location" {
  
  description = "Default location in azure"
  type        = string
}



variable "application" {
  description = "Default application description"
}



variable "environment" {

  description = "Shord environment name"
  type    = string

}

variable "aks-identity" {
  
  description = "Azure AKS managed Identity to be created or used"
  type        = string
}

variable "aks-resourcegroup" {
  
  type        = string
  description = "DEV,QA,PRD aks RG name"
}

variable "kubernetes_version" {

  type        = string
  description = "The kubernetes version supported"
}

variable "aks-network-rg" {
  type = string
  description = "The network resource group with the AKS vnet"
}

variable "environment_full" {
  type = string
  description = "Full environment name"
}

variable "keyvault_name" {
  description = "Keyvault to use"
  type = string
}


variable "aks-vnet" {
  description = "The vnet for AKS cluster"
}

variable "aks-subnet-1" {
  description= "the nodepool subnet for AKS nodepools"
}

variable "private_cluster" {
  description = "Boolean to use private cluster or not"
}

variable "public_autohorized_ranges" {
  type = list
  description = "Authorized ranges in case of a public cluster"
}
variable "kv_secrets_csi_driver" {
  default = false
}
variable "private_dns_zone" {
 description = "The private DNS zone"
}

variable "aks_name_prefix" {
  description = "The preffix for the cluster name"
}

variable "aks_administrators"{
  description = "The active directory group for AKS administrators"
}

variable "ssh_key_vault_secret" {
  description = "The public key from the keyvault for nodepools "
}

