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
  project = var.project
  region = var.region
  zone = var.location
 # credentials = "./keys.json"
}

terraform {
 backend "gcs" {
   bucket  = "terraformstate80"
   prefix  = "terraform/storage-account"
   
 }
}