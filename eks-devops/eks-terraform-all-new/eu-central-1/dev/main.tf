module "composition" {
  source = "../composition"
  ##vpc variables
  enable_vpc_network = var.enable_vpc_network
  PublicA_CIDR       = var.PublicA_CIDR
  PublicB_CIDR       = var.PublicB_CIDR
  PublicC_CIDR       = var.PublicC_CIDR
  WorkersA_cidr      = var.WorkersA_cidr
  WorkersB_cidr      = var.WorkersB_cidr
  WorkersC_cidr      = var.WorkersC_cidr
  DbACIDR            = var.DbACIDR
  DbBCIDR            = var.DbBCIDR
  DbCCIDR            = var.DbCCIDR
  eks_cluster_name   = var.eks_cluster_name
  vpc_cidr_block     = var.vpc_cidr_block
  azA                = var.azA
  azB                = var.azB
  azC                = var.azC

}
