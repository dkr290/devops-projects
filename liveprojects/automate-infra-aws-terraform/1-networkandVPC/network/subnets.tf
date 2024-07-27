# Create public and private subnets
locals {
  public_subnets = {
    publicA = var.publicA

    publicB = var.publicB

    publicC = var.publicC
  }
  private_app_subnets = {
    appA = var.AppA
    appB = var.AppB
    appC = var.AppC

  }
  private_db_subnets = {
    DbA = var.DbA
    DbB = var.DbB
    DbC = var.DbC

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
