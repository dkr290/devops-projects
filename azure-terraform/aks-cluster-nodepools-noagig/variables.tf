variable "subscription" {
  description = "The subscription ID"
  type        = string

}
# This is the location
variable "location" {
  description = "Default location in azure"
  type        = string
}

# This is the application this can be changed in tfvars file. Used for tags
variable "application" {
  description = "Default application tag"
  type        =  string
}


# Part of the tags section

variable "technical_owner"{
  description = "The Technical Owner Tag to be included"
  type        = string
}
#Part of the tags section
variable "environment" {

  description = "The Default Environment like  DEV,UAT,PRD this will prefix the resources created"
  type    = string

}



# The name of the managed identity
variable "aks-identity" {
  description = "Azure AKS managed Identity to be created or used"
  type        = string
}

# The name of the main aks resource group
variable "aks-resourcegroup" {
  type        = string
  description = "aks RG name"
}

# The fixed kubernetes verion.
variable "kubernetes_version" {
  type = string
  description = "fix the kubernetes version"
}



# This is the keyvault to used for adminuser and password for nodepools in case of a need to connect through ssh for troubleshooting purpose to connect
variable "keyvault_name" {
  description = "The keyvault for AKS and the nodepools password"
}

# The dedicated vnet for the nodepools (AKS)
variable "aks-vnet" {
  default     = "aks-vnet"
  description = " The vnet for AKS cluster"
}

# The subnet for exmaple used by astronomer AKS
variable "aks-subnet-1" {
  default = "aks-nodepools-subnet"
}

variable "aks-agic" {
  default = "agic"
  description = "The subnet for application gateway ingress controller"
  
}

# This is alsways true for bankingcircle clusters for now
variable "private_cluster"{
  default = "false"
}

# Ranges for the storage account
variable "public_autohorized_ranges" {
description = "[x.x.x.x/32,x.x.x.x/30]"
}
 # Whether to enable csi driver under investigation for now
variable "kv_secrets_csi_driver"{
  default = false
}

variable "private_dns_zone" {
  default= "aksuat.privatelink.northeurope.azmk8s.io"
  description = "the private DNS zone for aks"
}


# The aks preffix aks-astronomer or aks-bc
variable "aks_name_prefix" {
description = "The prefix for the aks cluster like aks-cluster"
}

variable "aks_administrators" {
  description = "Default Administrators in AKS"
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
//   default = "P@ssw0rd1234FprrrN5%%43" //to take from keyvault
//   description = "This variable defines the Windows admin password k8s Worker nodes"  
// }
