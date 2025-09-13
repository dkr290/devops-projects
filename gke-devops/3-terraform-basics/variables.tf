variable "gcp_project" {
  description = "GCP Project"
  type        = string
  default     = "peerless-window-333808"
}


variable "gcp_region" {

  description = "Region which gcp resources will be created "
  type        = string
  default     = "europe-west1"
}

variable "machine_type" {

  description = "Compute engine machine type"
  type        = string
  default     = "e2-micro"
}
