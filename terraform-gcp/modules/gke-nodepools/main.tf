resource "null_resource" "sleep" {
  provisioner "local-exec" {
    command = "sleep 40"
  }
}


resource "google_container_node_pool" "general" {
    depends_on     = [
      null_resource.sleep,
      google_container_cluster.gke,
      ]
  name       = var.node_pool_name
  cluster    = google_container_cluster.gke.name
  project = data.google_project.dev-k8s.project_id
  location = var.location
  version = var.gke_version

  
  node_locations = var.node_locations
  autoscaling{
    min_node_count = 1
    max_node_count = 3
  }
management {
  auto_repair = true
  auto_upgrade = true
}

  node_config {
    labels = {
      "role" = "general"
    }
    machine_type = "e2-medium"
    disk_size_gb = var.worker_nodes_disk_size
  
    metadata = {
      disable-legacy-endpoints = "true"
    }
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.svc-gke.email
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