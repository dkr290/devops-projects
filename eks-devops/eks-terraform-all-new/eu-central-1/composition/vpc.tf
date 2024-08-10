module "network" {
  count          = var.enable_vpc_network ? 1 : 0
  source         = "../../modules/vpc/"
  vpc_cidr_block = var.vpc_cidr_block
  publicA = {
    cidr_block = var.PublicA_CIDR
    az         = var.azA
    tags       = local.public_subnets_tags
  }
  publicB = {
    cidr_block = var.PublicB_CIDR
    az         = var.azB
    tags       = local.public_subnets_tags
  }
  publicC = {
    cidr_block = var.PublicC_CIDR
    az         = var.azC
    tags       = local.public_subnets_tags

  }
  WorkerA = {
    cidr_block = var.WorkersA_cidr
    az         = var.azA
    tags = {
      "Name" = "WorkersA"
    }

  }
  WorkerB = {
    cidr_block = var.WorkersB_cidr
    az         = var.azB
    tags = {
      "Name" = "WorkersB"
    }

  }
  WorkerC = {
    cidr_block = var.WorkersC_cidr
    az         = var.azC
    tags = {
      "Name" = "WorkersC"
    }

  }
  DbA = {
    cidr_block = var.DbACIDR
    az         = var.azA
    tags = {
      "Name" = "DbA"
    }

  }
  DbB = {
    cidr_block = var.DbBCIDR
    az         = var.azB
    tags = {
      "Name" = "DbB"
    }

  }
  DbC = {
    cidr_block = var.DbCCIDR
    az         = var.azC
    tags = {
      "Name" = "DbC"
    }

  }
  natEipA = {
    domain = "vpc"
  }




}

