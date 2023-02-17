resource "google_compute_network" "custom_vpc_network" {
  name                    = var.custom_vpc_name
  auto_create_subnetworks = false
  mtu                     = 1460
  project = var.project

  
}


resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  name          = "test-subnetwork"
  ip_cidr_range = var.address_space
  region        = var.region
  network       = google_compute_network.custom_vpc_network.id

  dynamic  "secondary_ip_range"{
     for_each = var.subnet_names
     content {
        range_name    =   secondary_ip_range.value.name
        ip_cidr_range = secondary_ip_range.value.address_prefix
     }

  } 
 
}
