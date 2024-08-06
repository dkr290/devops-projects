module "network" {
  source         = "./vpc"
  vpc_cidr_block = var.vpc_cidr_block
  publicA = {
    cidr_block = var.PublicA_CIDR
    az         = var.azA
    tags = {
      "Name" = "publicA"
    }
  }
  publicB = {
    cidr_block = var.PublicB_CIDR
    az         = var.azB
    tags = {
      "Name" = "publicB"
    }
  }
  publicC = {
    cidr_block = var.PublicC_CIDR
    az         = var.azC
    tags = {
      "Name" = "publicC"
    }
  }
  WorkersA = {
    cidr_block = var.WorkersA_cidr
    az         = var.azA
    tags = {
      "Name" = "WorkersA"
    }

  }
  AppB = {
    cidr_block = var.WorkersB_cidr
    az         = var.azB
    tags = {
      "Name" = "WorkersB"
    }

  }
  AppC = {
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

