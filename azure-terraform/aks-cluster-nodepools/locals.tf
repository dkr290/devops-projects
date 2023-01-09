locals {
  # This are the node labels which are assigned to the worker nodes
   node_labels = {
      "nodepool-type" = "default"
      "environment"   =  var.environment
      "nodepoolos"    = "linux"
     
    }
   

  technical_owner = var.technical_owner
  environment = var.environment
  application = var.application
  current_date= formatdate("DD MMM YYYY hh:mm ZZZ", timestamp()) 
 

  # The common tags use
  common_tags = {
    "Technical Owner"  =   local.technical_owner
    "Environment" =        local.environment
    "Created By"        = "Terraform Pipeline"
    "Application"       =  local.application
    "Creation Date"     =  local.current_date
    }

  
  
# The actual nodepools not by default and not for system pods. The idea here is to assign different vm size to it and this is the nodepools which will host 
# the actual applicatuions like astronomer or something else. the name will be attached to the actual kubernetes version like astro219 == kubernetes 21.9
# When we need to upgrade the kubernetes version with the same terraform as show below we can create a new nodepool like astro 224 = 22.4
# Then move all the pods to it, if it works decommission the old one as removing it from the terraform file. If Not we can fail back to the old nodepool. 

    node_pools ={
    ###comment out to delete it when the new one with 22.4 has been created and when it is disabled for sheuling new pods to it
    ## The idea is that this pool will contain astro219 with kubernetes version 21.9 and the other will be created when needs to abgrade to 22.4
    # pool219 = {
    #   name = "pool219"
    #   # autoscaling from 2 to more nodes
    #   max_nodes = 3
    #   min_nodes = 2
    #   ## the vm size
    #   vm_size = "Standard_B2s"
    #   # the kubernetes version
    #   k_version = "1.21.9"
    #   # The disk size of the worker nodes
    #   os_disk_size = 32
    #   node_labels = {
    #    "nodepool-type" = "ondemand"
    #    "environment"   = var.environment
    #    "nodepoolos"    = "linux"
    #    "app"           = "aks"
       
    # }
   ##  if we want to taint the pool, if not just remove the value
     #node_taints = ["key=value:NoSchedule"]
 
  # }
    pool224 = {
      name = "pool224"
      # autoscaling from 2 to more nodes
      max_nodes = 3
      min_nodes = 2
      ## the vm size
      vm_size = "Standard_D2as_v4"
      # the kubernetes version
      k_version = "1.22.4"
      # The disk size of the worker nodes
      os_disk_size = 32
      node_labels = {
       "nodepool-type" = "ondemand"
       "environment"   = var.environment
       "nodepoolos"    = "linux"
       "app"           = "aks"
       
    }
   ##  if we want to taint the pool, if not just remove the value
     #node_taints = ["key=value:NoSchedule"]
 
  }

    }
}


