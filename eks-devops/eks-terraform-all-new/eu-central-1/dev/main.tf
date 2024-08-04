module "network" {
  source         = "./vpc"
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
  WorkersA = {
    cidr_block = var.WorkersA_cidr
    az         = "eu-central-1a"
    tags = {
      "Name" = "WorkersA"
    }

  }
  AppB = {
    cidr_block = var.WorkersB_cidr
    az         = "eu-central-1b"
    tags = {
      "Name" = "WorkersB"
    }

  }
  AppC = {
    cidr_block = var.WorkersC_cidr
    az         = "eu-central-1c"
    tags = {
      "Name" = "WorkersC"
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
  natEipA = {
    domain = "vpc"
  }




}

