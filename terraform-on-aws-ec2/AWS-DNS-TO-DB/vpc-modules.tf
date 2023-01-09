module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"
  name = "${local.name}-${var.vpc_name}"
  cidr = var.vpc_cidr_block

  azs             = var.vpc_availability_zones
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets
  
  #Database subnerts
  create_database_subnet_group = var.vpc_create_database_subnet_group
  create_database_subnet_route_table = var.vpc_create_database_subnet_route_table
  database_subnets  = var.vpc_database_subnets
  create_database_internet_gateway_route = false 
  create_database_nat_gateway_route = false

  # NAT gateways for outbound communication

  enable_nat_gateway = var.vpc_enable_nat_gateway
  single_nat_gateway = var.vpc_single_nat_gateway


  # VPC DNS parameters

  enable_dns_hostnames = true
  enable_dns_support = true

  
tags = local.common_tags
vpc_tags = local.common_tags

database_subnet_tags = {
    Type = "Private database subnets"
}

 
  private_subnet_tags = {
      Type = "private subnets"
  }




  public_subnet_tags = {
      Type = "public subnets"
  }


}

