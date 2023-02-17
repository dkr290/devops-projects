variable "subnet_names" {
  default = {
    subnet1 = {
      name           = "subnet1"
      address_prefix = "10.0.1.0/24"
    }
    subnet2 = {
      name           = "subnet2"
      address_prefix = "10.0.2.0/24"
    }
  }
}

variable "project" {
  description = "The project ID where all resources will be launched."
  type        = string
}

variable "location" {
  description = "The location (region or zone) of the GKE cluster."
  type        = string
  default = "europe-west1-b"
}

variable "region" {
  description = "The region for the network. If the cluster is regional, this must be the same region. Otherwise, it should be the region of the zone."
  type        = string
  default = "europe-west1"
}


variable "custom_vpc_name" {
  default = "custom-vpc"
}

variable "address_space" {
  default = "10.2.0.0/16"
}