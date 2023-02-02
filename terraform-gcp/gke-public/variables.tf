# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are expected to be passed in by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "project" {
  description = "The project ID where all resources will be launched."
  type        = string
}

variable "location" {
  description = "The location (region or zone) of the GKE cluster."
  type        = string
}

variable "region" {
  description = "The region for the network. If the cluster is regional, this must be the same region. Otherwise, it should be the region of the zone."
  type        = string
}


# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# Some of them have defaults another goes to tfvars, if you want you can override with the tfvars file.
# ---------------------------------------------------------------------------------------------------------------------
variable "business_division" {
  description = "Business division in the large organization"
  type = string
  

}
variable "environment" {
  description = "environment"
  type = string
}
variable "cluster_name" {
  description = "The name of the Kubernetes cluster."
  type        = string
 
}
variable remove_default_node_pool{
  description = "true or false for the default node pool"
  type = bool
}

variable worker_nodes_disk_size{
  description = "disk size for the worker nodes of the default pool"
  type = string
}

variable "release_channel" {
  description = "the release channel"
  type=string
  
}

variable "kubernetes_version" {
  description = "kubernetes version"
  type = string
  
}

variable "enable_vpc_router" {
  type = bool
  description = "Whether to enable o not the Router"
}

variable "enable_vpc_nat" {
  type = bool
  description = "Whether to enable nat router for example in case of private gke cluster"
  
}
# For the example /16 network for the VPC. Note that when changing the size of the network,

variable "vpc_cidr_block" {
  description = "The IP address range of the VPC in CIDR notation. A prefix of /16 is recommended. Do not use a prefix higher than /27."
  type        = string
  default     = "10.6.0.0/16"
}

# For example /16 network for the secondary range. Note that when changing the size of the network,

variable "vpc_secondary_cidr_block" {
  description = "The IP address range of the VPC's secondary address range in CIDR notation. A prefix of /16 is recommended. Do not use a prefix higher than /27."
  type        = string
  default     = "10.7.0.0/16"
}

variable "public_subnetwork_secondary_range_name" {
  description = "The name associated with the pod subnetwork secondary range, used when adding an alias IP range to a VM instance. The name must be 1-63 characters long, and comply with RFC1035. The name must be unique within the subnetwork."
  type        = string
  default     = "public-cluster"
}

variable "public_services_secondary_range_name" {
  description = "The name associated with the services subnetwork secondary range, used when adding an alias IP range to a VM instance. The name must be 1-63 characters long, and comply with RFC1035. The name must be unique within the subnetwork."
  type        = string
  default     = "public-services"
}

variable "public_services_secondary_cidr_block" {
  description = "The IP address range of the VPC's public services secondary address range in CIDR notation. A prefix of /16 is recommended. Do not use a prefix higher than /27. Note: this variable is optional and is used primarily for backwards compatibility, if not specified a range will be calculated using var.secondary_cidr_block, var.secondary_cidr_subnetwork_width_delta and var.secondary_cidr_subnetwork_spacing."
  type        = string
  default     = null
}

variable "private_services_secondary_cidr_block" {
  description = "The IP address range of the VPC's private services secondary address range in CIDR notation. A prefix of /16 is recommended. Do not use a prefix higher than /27. Note: this variable is optional and is used primarily for backwards compatibility, if not specified a range will be calculated using var.secondary_cidr_block, var.secondary_cidr_subnetwork_width_delta and var.secondary_cidr_subnetwork_spacing."
  type        = string
  default     = null
}

variable "secondary_cidr_subnetwork_width_delta" {
  description = "The difference between your network and subnetwork's secondary range netmask; an /16 network and a /20 subnetwork would be 4."
  type        = number
  default     = 4
}

variable "secondary_cidr_subnetwork_spacing" {
  description = "How many subnetwork-mask sized spaces to leave between each subnetwork type's secondary ranges."
  type        = number
  default     = 0
}

variable "enable_vertical_pod_autoscaling" {
  description = "Enable vertical pod autoscaling"
  type        = string
  default     = true
}

variable "enable_workload_identity" {
  description = "Enable Workload Identity on the cluster"
  default     = true
  type        = bool
}

# ---------------------------------------------------------------------------------------------------------------------
# TEST PARAMETERS
# These parameters are only used during testing and should not be touched.
# ---------------------------------------------------------------------------------------------------------------------

variable "override_default_node_pool_service_account" {
  description = "When true, this will use the service account that is created for use with the default node pool that comes with all GKE clusters"
  type        = bool
  default     = false
}