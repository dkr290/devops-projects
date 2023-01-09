variable "subscription" {
  default     = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  description = "Subscription ID"
  type        = string

}

variable "location" {
  default     = "North Europe"
  description = "Default location in azure"
  type        = string
}


variable "application" {
  default = "AKS"
}

variable "technical_owner"{
  default = "User01"
}
variable "environment" {

  default = "UAT"
  type    = string

}

variable "aks-identity" {
  default     = "aks-uat"
  description = "Azure AKS managed Identity to be created or used"
  type        = string
}

variable "aks-resourcegroup" {
  default     = "test-aks-rg"
  type        = string
  description = "UAT aks RG name"
}

variable "kubernetes_version" {
  default = "1.21.9"
  type = string
  description = "fix the kubernetes version"
}

variable "aks-network-rg" {
  default     = "network-aks-uat-rg"
  description = "The network resource group with the AKS vnet"
}

variable "keyvault_name" {
  default = "aks-kv-uat"
}
variable "kv_secrets_csi_driver"{
  default = false
}

variable "aks-vnet" {
  default     = "vnet-uat-k8s"
  description = " The vnet for AKS cluster"
}

variable "aks-subnet-1" {
  default = "aks-cl-uat"
}


variable "private_cluster"{
  default = "false"
}

variable "public_authorized_ranges" {
  default = ["xxx.xxx.xx.xx/32"]
}

variable "aks_name_prefix" {
  default = "aks-cluster"
}



# No need to enable windows node pools for now

// variable "windows_admin_username" {
//   type = string
//   default = "azureuser"
//   description = "This variable defines the Windows admin username k8s Worker nodes"  
// }

// # Windows Admin Password for k8s worker nodes
// variable "windows_admin_password" {
//   type = string
//   default = "xxxxxxx" //to take from keyvault
//   description = "This variable defines the Windows admin password k8s Worker nodes"  
// }
