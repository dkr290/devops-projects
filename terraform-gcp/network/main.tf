resource "google_compute_network" "auto_vpc_network" {
  name                    = "auto-vpc-network"
  auto_create_subnetworks = true
  mtu                     = 1460
}


module custom-vpc {
  source = "../modules/custom-vpc"
  zone = var.zone
  region = var.region
  project_id = var.project_id
  subnets      = local.subnets
  custom_vpc_name = var.custom_vpc_name
}



