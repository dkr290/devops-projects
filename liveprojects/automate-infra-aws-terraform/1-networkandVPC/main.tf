module "network" {
  source         = "./network"
  vpc_cidr_block = var.vpc_cidr_block
  publicA = {
    cidr_block = "172.16.1.0/24"
    az         = "eu-central-1a"
    tags = {
      "Name" = "publicA"
    }
  }
  publicB = {
    cidr_block = "172.16.2.0/24"
    az         = "eu-central-1b"
    tags = {
      "Name" = "publicB"
    }
  }
  publicC = {
    cidr_block = "172.16.3.0/24"
    az         = "eu-central-1c"
    tags = {
      "Name" = "publicC"
    }
  }
  AppA = {
    cidr_block = "172.16.4.0/24"
    az         = "eu-central-1a"
    tags = {
      "Name" = "appA"
    }

  }
  AppB = {
    cidr_block = "172.16.5.0/24"
    az         = "eu-central-1b"
    tags = {
      "Name" = "appB"
    }

  }
  AppC = {
    cidr_block = "172.16.6.0/24"
    az         = "eu-central-1c"
    tags = {
      "Name" = "appC"
    }

  }
  DbA = {
    cidr_block = "172.16.8.0/24"
    az         = "eu-central-1a"
    tags = {
      "Name" = "DbA"
    }

  }
  DbB = {
    cidr_block = "172.16.9.0/24"
    az         = "eu-central-1b"
    tags = {
      "Name" = "DbB"
    }

  }
  DbC = {
    cidr_block = "172.16.10.0/24"
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
module "compute" {
  source        = "./compute"
  key_pair_name = "my_ec2_custom_key"
  BastionSG     = ""


}
