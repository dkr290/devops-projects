# Terraform Remote State Datasource - Remote Backend azure storeage account
data "terraform_remote_state" "bc-aks" {
   backend = "azurerm" 
    config = { 

    resource_group_name  = "aks-rg"
    storage_account_name = "tfstatebucketxxxxxx-samefrom1"
    container_name       = "tf-state"
    key                  = "aks-cluster.tfstate"
    subscription_id      = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"


  }
 
}