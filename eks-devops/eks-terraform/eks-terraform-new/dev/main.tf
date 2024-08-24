
#removing or not bastion host
module "bastionhost" {
  count             = var.enable_bastion_host ? 1 : 0
  source            = "../modules/bastionhost/"
  ingress_from_port = var.ingress_from_port
  ingress_to_port   = var.ingress_to_port
  vpc_id            = module.network[0].vpc_id
  public_subnets = {
    subnetA = {
      subnet_id = module.network[0].publicSubnetA,
      tags = merge(
        var.common_tags,
        {
          "Name" = "BastionHost1"
        }
      )
    }
  }
  ssh_keypair = var.ssh_bastion_keypair
}
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
}
module "eks_private_nodes" {
  source                 = "../modules/eks-nodes/"
  nodepool_keypair       = var.ssh_keypair
  environment            = var.environment
  cluster_name           = var.eks_cluster_name
  cluster_id             = module.eks_control.cluster_id
  subnet_ids             = [module.network[0].WorkersSubnetA, module.network[0].WorkersSubnetB, module.network[0].WorkersSubnetC]
  node_group_name        = "private_ng"
  tags                   = local.private_nodegroup_tags
  eks_nodegroup_role_arn = module.eks_control.eks_nodegroup_role_arn
  depends_on             = [module.eks_control]
}
module "addons" {
  source     = "../modules/eks_addons/"
  cluster_id = module.eks_control.cluster_id
  addons     = var.addons
  depends_on = [module.eks_control, module.eks_public_nodes, module.eks_private_nodes]
}
