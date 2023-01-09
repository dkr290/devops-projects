terraform {
  # 1. Required Version Terraform
  required_version = ">= 1.0"
  # 2. Required Terraform Providers  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"

    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
## The backend is in fact the storage account of where the terraform state will be stored
  # backend "azurerm" {

  #   resource_group_name  = "storage-account-rg"
  #   storage_account_name = "storageaccountname"
  #   container_name       = "aks-contianer"
  #   key                  = "thefile.tfstate"
  #   subscription_id      = "xxxxxxxxxxxxxxxxxxxxxxx"

  # }

}

provider "azurerm" {

  features {
    resource_group {
     prevent_deletion_if_contains_resources = false
      }
    }
  subscription_id = var.subscription
}
