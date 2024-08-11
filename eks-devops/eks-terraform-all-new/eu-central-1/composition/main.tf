module "bastionhost" {
  count             = var.enable_bastion_host ? 1 : 0
  source            = "../../modules/bastionhost/"
  ingress_from_port = var.ingress_from_port
  ingress_to_port   = var.ingress_to_port
  vpc_id            = module.network[0].vpc_id
  public_subnets    = var.public_subnets
  ssh_keypair       = var.ssh_keypair
}
