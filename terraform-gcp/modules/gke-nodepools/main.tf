

resource "google_container_node_pool" "general" {
  for_each = var.gke_node_pools 

  name       = each.value.name
  cluster    = var.gke_cluster
  project = var.project
  location = var.location
  version = var.kubernetes_version

  
  node_locations = each.value.node_locations
  autoscaling{
    min_node_count = each.value.min_nodes
    max_node_count = each.value.max_nodes
  }
management {
  auto_repair = true
  auto_upgrade = true
}

  node_config {
    labels = {
      "role" = "general"
    }
    machine_type = each.value.machine_type
    disk_size_gb = each.value.os_disk_size
  
    metadata = {
      disable-legacy-endpoints = "true"
    }
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = var.gke_serviceaccout
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
  
    #  "https://www.googleapis.com/auth/servicecontrol",
    #  "https://www.googleapis.com/auth/trace.append"
    ]
  }

  
}