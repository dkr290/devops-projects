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

  # backend "azurerm" {

  #   resource_group_name  = "<rg-of-storage-account>"
  #   storage_account_name = "<somestorageaccount>"
  #   container_name       = "aks-deployment"
  #   key                  = "aks-cluster.tfstate"
  #   subscription_id      = "xxxxxxxxxxxxxxxxxxxxxxxx"

  # }

}

provider "azurerm" {

  features {}
  subscription_id = var.subscription
}
