locals {
  node_labels = {
    "nodepool-type" = "default"
    "environment"   = var.environment
    "nodepoolos"    = "linux"

  }



  environment     = var.environment_full
  application     = var.application
  current_date    = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())



  common_tags = {
   
    "Environment"     = local.environment
    "Created By"      = "Terraform"
    "Application"     = local.application
    "Creation Date"   = local.current_date
  }






}
