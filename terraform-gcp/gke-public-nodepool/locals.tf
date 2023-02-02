locals {

gke_node_pools = {
  
    
     nodepool-base = {
       name         = "general"
       max_nodes    = 3
       min_nodes    = 1
       machine_type      = "e2-medium"
       os_disk_size = 30
       node_locations   = ["europe-north1-a", "europe-north1-c"]
       
     }
   }

}