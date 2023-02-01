module "gke_cluster" {
    source = "../modules/gke"
    cluster_name = var.cluster_name
    project  = var.project
    location = var.location
    network  = module.vpc_network.network
    subnetwork                    = module.vpc_network.public_subnetwork
    cluster_secondary_range_name  = module.vpc_network.public_subnetwork_secondary_range_name
    services_secondary_range_name = module.vpc_network.public_services_secondary_range_name
    enable_vertical_pod_autoscaling = var.enable_vertical_pod_autoscaling
    enable_workload_identity        = var.enable_workload_identity
    business_division = var.business_division
    environment = var.environment
    remove_default_node_pool = var.remove_default_node_pool
    worker_nodes_disk_size = var.worker_nodes_disk_size
    release_channel= var.release_channel
    kubernetes_version = var.kubernetes_version
  resource_labels = {
    environment = "development"
  }
}
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}
module "vpc_network" {
  source = "../modules/vpc-network"

  name_prefix = "${var.cluster_name}-network-${random_string.suffix.result}"
  project     = var.project
  region      = var.region

  cidr_block           = var.vpc_cidr_block
  secondary_cidr_block = var.vpc_secondary_cidr_block

  public_subnetwork_secondary_range_name = var.public_subnetwork_secondary_range_name
  public_services_secondary_range_name   = var.public_services_secondary_range_name
  public_services_secondary_cidr_block   = var.public_services_secondary_cidr_block
  private_services_secondary_cidr_block  = var.private_services_secondary_cidr_block
  secondary_cidr_subnetwork_width_delta  = var.secondary_cidr_subnetwork_width_delta
  secondary_cidr_subnetwork_spacing      = var.secondary_cidr_subnetwork_spacing
}
    