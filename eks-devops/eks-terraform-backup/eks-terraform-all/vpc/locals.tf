
locals {
  tags = {
    "Name"                                      = "EKS VPC"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  vpc_cidr_prefix      = split("/", var.vpc_cidr_block)[0]
  public_subnet_cidrs  = [for i in range(2) : cidrsubnet(var.vpc_cidr_block, 8, i)]
  private_subnet_cidrs = [for i in range(2, 4) : cidrsubnet(var.vpc_cidr_block, 8, i)]


}
