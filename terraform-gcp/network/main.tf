resource "google_compute_network" "auto_vpc_network" {
  name                    = "auto-vpc-network"
  auto_create_subnetworks = true
  mtu                     = 1460
}


module custom_network {
  source = "../modules/cloud-storage"
  zone = var.zone
  region = var.region
  project_id = var.project_id
  subnets      = local.subnets
}



# resource "google_compute_subnetwork" "gke-windows-hosts" {
#   name          = "gke-windows-hosts"
#   ip_cidr_range = "10.151.11.0/24"
#   region        = "europe-north1"
#   network       = google_compute_network.custom_vpc_network.id
  
# }

# resource "google_compute_subnetwork" "gke-private-links" {
#   name          = "gke-private-links"
#   ip_cidr_range = "10.151.12.0/24"
#   region        = "europe-north1"
#   network       = google_compute_network.custom_vpc_network.id
  
# }



