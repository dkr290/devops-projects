#settings block

terraform {
  required_version = "~> 1.13.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.36.0"
    }
  }

}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

provider "google" {
  project = "peerless-window-333808"
  region  = "europe-west1"
  alias   = "europe-west1"
}

provider "google" {
  project = "peerless-window-333808"
  region  = "us-central1"
  alias   = "us-central1"
}

