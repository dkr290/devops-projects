# Project and region settings
variable "gcp_project_id" {
  description = "The Google Cloud Project ID"
  type        = string
}

variable "gcp_region" {
  description = "The Google Cloud region to deploy the instance"
  type        = string
  default     = "europe-west4" # L4 is widely available here
}

variable "gcp_zone" {
  description = "The zone within the region to deploy the instance"
  type        = string
  default     = "europe-west4-a"
}

# Machine type (4 vCPUs and 16 GiB RAM is the minimum for the L4 GPU)
variable "machine_type" {
  description = "The machine type for the VM"
  type        = string
  default     = "g2-standard-4" # Minimum machine type for 1x L4
}
