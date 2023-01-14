terraform {
  required_version = ">=1.3.0"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~>4.40"
    }
  }
}

provider "google" {
  # Configuration options
  project = var.project_id
  region = var.region
  zone = var.zone
 # credentials = "./keys.json"
}

terraform {
 backend "gcs" {
   bucket  = "terraformstate80"
   prefix  = "terraform/vpc-network"
   
 }
}