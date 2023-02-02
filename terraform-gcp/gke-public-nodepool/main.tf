

module "gke_nodepools" {
    source = "../modules/gke-nodepools"
    gke_serviceaccout = data.terraform_remote_state.gke-cluster.outputs.gke_service_account
    gke_cluster = data.terraform_remote_state.gke-cluster.outputs.gke_cluster_id
    project = var.project
    location = var.location
    gke_node_pools = local.gke_node_pools
    kubernetes_version = data.terraform_remote_state.gke-cluster.outputs.gke_master_version
  
}