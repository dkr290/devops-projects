# Create public and private subnets
locals {
  public_subnets = {
    publicA = var.publicA

    publicB = var.publicB

    publicC = var.publicC
  }
  private_app_subnets = {
    appA = {
      cidr_block = "172.16.4.0/24"
      az         = "eu-central-1a"
      tags = {
        "Name" = "appA"
      }

    }
    appB = {
      cidr_block = "172.16.5.0/24"
      az         = "eu-central-1b"
      tags = {
        "Name" = "appB"
      }

    }
    appC = {
      cidr_block = "172.16.6.0/24"
      az         = "eu-central-1c"
      tags = {
        "Name" = "appC"
      }

    }

  }
  private_db_subnets = {
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

  }

}

resource "aws_subnet" "public" {
  for_each                = local.public_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = each.value.tags

}
resource "aws_subnet" "privateApp" {
  for_each          = local.private_app_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  tags = each.value.tags

}
resource "aws_subnet" "privateDb" {
  for_each          = local.private_db_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  tags = each.value.tags

}
