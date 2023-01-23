locals {
 

  environment     = var.environment_full
  application     = var.application
  current_date    = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())



  common_tags = {

    "Environment"     = local.environment
    "Created By"      = "Terraform Pipeline"
    "Application"     = local.application
    "Creation Date"   = local.current_date
  }





 records = {
   
    
     test = {
       name         = "test"
       ttl          = "300"
       records    = ["10.10.0.200"] // change it accordingly to
      
     }

  }

}
