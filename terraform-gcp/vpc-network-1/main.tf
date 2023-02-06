resource "google_compute_network" "custom_vpc_network" {
  name                    = var.custom_vpc_name
  auto_create_subnetworks = false
  mtu                     = 1460
  project = var.project_id

  dynamic "subnets" {
    
  }
  
}
