# Terraform Provider Configuration: google
provider "google" {
  project = "peerless-window-333808"
  region  = "europe-west1"
}

# Resource: VPC
resource "google_compute_network" "myvpc" {
  name                    = "vpc1"
  auto_create_subnetworks = false
}

# Resource: Subnet
resource "google_compute_subnetwork" "mysubnet" {
  name          = "subnet1"
  region        = "europe-west1"
  ip_cidr_range = "10.128.0.0/20"
  network       = google_compute_network.myvpc.id // GET VPC ID
}
