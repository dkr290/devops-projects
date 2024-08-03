module "network" {
  source         = "./network"
  vpc_cidr_block = var.vpc_cidr_block
  publicA = {
    cidr_block = var.PublicA_CIDR
    az         = "eu-central-1a"
    tags = {
      "Name" = "publicA"
    }
  }
  publicB = {
    cidr_block = var.PublicB_CIDR
    az         = "eu-central-1b"
    tags = {
      "Name" = "publicB"
    }
  }
  publicC = {
    cidr_block = var.PublicC_CIDR
    az         = "eu-central-1c"
    tags = {
      "Name" = "publicC"
    }
  }
  AppA = {
    cidr_block = var.AppACIDR
    az         = "eu-central-1a"
    tags = {
      "Name" = "appA"
    }

  }
  AppB = {
    cidr_block = var.AppBCIDR
    az         = "eu-central-1b"
    tags = {
      "Name" = "appB"
    }

  }
  AppC = {
    cidr_block = var.AppCCIDR
    az         = "eu-central-1c"
    tags = {
      "Name" = "appC"
    }

  }
  DbA = {
    cidr_block = var.DbACIDR
    az         = "eu-central-1a"
    tags = {
      "Name" = "DbA"
    }

  }
  DbB = {
    cidr_block = var.DbBCIDR
    az         = "eu-central-1b"
    tags = {
      "Name" = "DbB"
    }

  }
  DbC = {
    cidr_block = var.DbCCIDR
    az         = "eu-central-1c"
    tags = {
      "Name" = "DbC"
    }

  }
  natEipB = {
    domain = "vpc"
  }
  natEipA = {
    domain = "vpc"
  }
  natEipC = {
    domain = "vpc"
  }




}
module "security" {
  source = "./security/"
  vpc_id = module.network.vpc_id

}

module "compute" {
  source        = "./compute"
  key_pair_name = "my_ec2_custom_key"

  publicSubnetA = {
    subnet_id = module.network.publicSubnetA
    bastionSG = module.security.BastionSG
    tags = {
      Name = "BastionHostA"
    }
  }
  publicSubnetB = {
    subnet_id = module.network.publicSubnetB
    bastionSG = module.security.BastionSG
    tags = {
      Name = "BastionHostB"
    }

  }
  publicSubnetC = {
    subnet_id = module.network.publicSubnetC
    bastionSG = module.security.BastionSG

    tags = {
      Name = "BastionHostC"
    }

  }
  appSubnetA = {
    subnet_id = module.network.privateAppSubnetA
    AppSG     = module.security.AppSG
    tags = {
      Name = "AppHostA"
    }
  }
  appSubnetB = {
    subnet_id = module.network.privateAppSubnetB
    AppSG     = module.security.AppSG
    tags = {
      Name = "AppHostB"
    }
  }
  appSubnetC = {
    subnet_id = module.network.privateAppSubnetC
    AppSG     = module.security.AppSG
    tags = {
      Name = "AppHostC"
    }
  }



  depends_on = [module.security]




}
