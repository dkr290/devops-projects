#settings block

terraform {
  required_version = "~> 1.12.0"
  required_providers {
   google = {
      source = "hashicorp/google"
      version = "~> 6.36.0"
    } 
  }

}

provider "google" {
  project =  "peerless-window-333808"
  region = "europe-west1"
}

