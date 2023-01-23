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





  aks_node_pools = {
    ###comment out to delete it when the new one with 22.4 has been created and when it is disabled for sheuling new pods to it
    ## The idea is that this pool will contain astro219 with kubernetes version 21.9 and the other will be created when needs to abgrade to 22.4
    
     pool254d16 = {
       name         = "pool254d16"
       max_nodes    = 10
       min_nodes    = 3
       vm_size      = "Standard_D16as_v4"
       k_version    = "1.25.4"
       os_disk_size = 256
       node_labels = {
         "nodepool-type" = "common"
         "environment"   = var.environment
         "nodepoolos"    = "linux"
         "app"           = "common"

       }
    #   ##  if we want to taint the pool, if not just remove the value
    #   #node_taints = ["key=value:NoSchedule"]

     }
    #   pool2312p32 = {
    #    name         = "pool2312p32"
    #    max_nodes    = 10
    #    min_nodes    = 1
    #    vm_size      = "Standard_D8ds_v4"
    #    k_version    = "1.23.12"
    #    os_disk_size = 256
    #    node_labels = {
    #     "nodepool-type" = "common"
    #     "environment"   = var.environment
    #     "nodepoolos"    = "linux"
    #     "app"           = "app1"
    #     "department"    = "Some Departement"

    #    }
    # #   ##  if we want to taint the pool, if not just remove the value
    # #   #node_taints = ["key=value:NoSchedule"]
  


    #  }

  
  }

}
