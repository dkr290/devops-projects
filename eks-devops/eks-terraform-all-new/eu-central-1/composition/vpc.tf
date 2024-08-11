module "network" {
  count          = var.enable_vpc_network ? 1 : 0
  source         = "../../modules/vpc/"
  vpc_cidr_block = var.vpc_cidr_block
  publicA = {
    cidr_block = var.PublicA_CIDR
    az         = var.azA
    tags       = local.public_subnetA_tags
  }
  publicB = {
    cidr_block = var.PublicB_CIDR
    az         = var.azB
    tags       = local.public_subnetB_tags
  }
  publicC = {
    cidr_block = var.PublicC_CIDR
    az         = var.azC
    tags       = local.public_subnetC_tags

  }
  WorkerA = {
    cidr_block = var.WorkersA_cidr
    az         = var.azA
    tags       = local.workers_subnetsA_tags

  }
  WorkerB = {
    cidr_block = var.WorkersB_cidr
    az         = var.azB
    tags       = local.workers_subnetsB_tags

  }
  WorkerC = {
    cidr_block = var.WorkersC_cidr
    az         = var.azC
    tags       = local.workers_subnetsC_tags

  }
  DbA = {
    cidr_block = var.DbACIDR
    az         = var.azA
    tags       = local.database_subnetsA_tags

  }
  DbB = {
    cidr_block = var.DbBCIDR
    az         = var.azB
    tags       = local.database_subnetsB_tags

  }
  DbC = {
    cidr_block = var.DbCCIDR
    az         = var.azC
    tags       = local.database_subnetsC_tags

  }
  natEipA = {
    domain = "vpc"
  }




}

