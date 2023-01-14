resource "google_compute_network" "custom_vpc_network" {
  name                    = var.custom_vpc_name
  auto_create_subnetworks = false
  mtu                     = 1460
  project = var.project_id
  
}

resource "google_compute_subnetwork" "gke-nodepools-subnetwork" {
  for_each      =  var.subnets
  name          =  each.value.name 
  ip_cidr_range =  each.value.cidr 
  region        =  each.value.region 
  network       =  google_compute_network.custom_vpc_network.id
  
}