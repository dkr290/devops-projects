locals {
   default_nodepool_node_labels = {
      "nodepool-type" = "system"
      "environment"   = "dev"
      "nodepoolos"    = "linux"
      
    }
  
  node_pools ={
    #comment out to delete it when the new one with 22.4 has been created and when it is disabled for sheuling new pods to it
    blue219 = {
      name = "blue219"
      max_nodes = 3
      min_nodes = 1
      vm_size = "Standard_B2s"
      kubernetes_version = "1.21.9"
       os_disk_size = 30
      node_labels = {
       "nodepool-type" = "blue219"
       "environment"   = "dev"
       "nodepoolos"    = "linux"
       "app"           = "astronomer"
       "astronomer"    = "true"
    }
   ##  if we want to taint the pool, if not just remove the value
     #node_taints = ["key=value:NoSchedule"]
 
  }

  #  blue224 = {
  #     name = "blue224"
  #     max_nodes = 3
  #     min_nodes = 1
  #     vm_size   "Standard_B2s"  
  #     kubernetes_version = "1.22.4"
  #     os_disk_size = 30
  #     node_labels = {
  #      "nodepool-type" = "blue224"
  #      "environment"   = "dev"
  #      "nodepoolos"    = "linux"
  #      "app"           = "astronomer"
  #      "astronomer"    = "true"
  #   }
  #    # if we want to taint the pool, if not just remove the value
  #    #node_taints = ["key=value:NoSchedule"]
 
  #  }

  #  test = {
  #     name = "test"
  #     max_nodes = 3
  #     min_nodes = 1
   #    vm_size = "Standard_B2s"
      #     kubernetes_version = "1.22.4"
   # os_disk_size = 128
  #     node_labels = {
  #      "nodepool-type" = "test"
  #      "environment"   = "dev"
  #      "nodepoolos"    = "linux"
  #      "app"           = "test"
       
  #   }
  #    # if we want to taint the pool, if not just remove the value
  #    #node_taints = ["key=value:NoSchedule"]
 
  #  }
  }

 

  
   


  technical_owner = var.technical_owner
  environment = var.environment
  application = var.application
  current_date= formatdate("DD MMM YYYY hh:mm ZZZ", timestamp()) 
 

  
  common_tags = {
    "Technical Owner"  =   local.technical_owner
    "Environment" =        local.environment
    "Created By"        = "Terraform Pipeline"
    "Application"       =  local.application
    "Creation Date"     =  local.current_date
    }
}
