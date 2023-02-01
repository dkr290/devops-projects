locals {
  owners = lower("${var.business_division}")
  environment = var.environment
 # name = "${var.business_division}-${var.environment}"

 name = "${local.owners}-${local.environment}"
 common_tags ={
    owners = local.owners
    environment = local.environment
 }



 
gke_cluster_name = "${local.name}-${var.cluster_name}"
latest_version     = var.kubernetes_version
kubernetes_version = var.kubernetes_version
network_project    = var.network_project != "" ? var.network_project : var.project
}