terraform {
  # 1. Required Version Terraform
  required_version = ">= 1.0"
  # 2. Required Terraform Providers  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.60"

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

  backend "azurerm" {

    resource_group_name  = "aks-rg"
    storage_account_name = "tfstatebucketxxxx-sameas1"
    container_name       = "tf-state"
    key                  = "aks-nodepools.tfstate"
    subscription_id      = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  }

}

provider "azurerm" {

  features {}
  subscription_id = var.subscription
}
