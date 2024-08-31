
## using together the two for control plane and nodegroups
module "eks_control" {
  source                          = "../modules/eks/"
  environment                     = var.environment
  cluster_version                 = var.cluster_version
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  subnet_ids                      = [module.network[0].publicSubnetA, module.network[0].publicSubnetB, module.network[0].publicSubnetC]
  cluster_name                    = var.eks_cluster_name
  cluster_service_ipv4_cidr       = var.cluster_service_ipv4_cidr
  depends_on                      = [module.network]
  common_tags                     = var.common_tags

}
module "eks_public_nodes" {
  source                 = "../modules/eks-nodes/"
  nodepool_keypair       = var.ssh_keypair
  environment            = var.environment
  cluster_name           = var.eks_cluster_name
  cluster_id             = module.eks_control.cluster_id
  subnet_ids             = [module.network[0].publicSubnetA, module.network[0].publicSubnetB, module.network[0].publicSubnetC]
  node_group_name        = var.node_group_name
  tags                   = local.public_nodegroup_tags
  eks_nodegroup_role_arn = module.eks_control.eks_nodegroup_role_arn
  depends_on             = [module.eks_control]
  desired_size           = var.desired_size
  min_size               = var.min_size
  max_size               = var.max_size

}
module "addons" {
  source     = "../modules/eks_addons/"
  cluster_id = module.eks_control.cluster_id
  addons     = var.addons
  depends_on = [module.eks_control, module.eks_public_nodes]
}
module "cluster_autoscaler" {
  source                          = "../modules/cluster-autoscaler/"
  eks_nodegroup_role_name         = module.eks_control.eks_nodegroup_role_name
  eks_cluster                     = module.eks_public_nodes.eks_cluster_name #this creates dependency
  aws_iam_openid_connect_provider = module.eks_control.aws_iam_openid_connect_provider
  cluster_oidc_issuer_url         = module.eks_control.cluster_oidc_issuer_url
  eks_endpoint                    = module.eks_control.cluster_endpoint
  eks_certificate_authority_data  = module.eks_control.cluster_certificate_authority_data
  aws_region                      = var.aws_region
  cluster_id                      = module.eks_control.cluster_id
}
