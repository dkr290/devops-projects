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


}
