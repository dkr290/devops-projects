locals {
  bastion_host_common_tags = merge(
    var.common_tags,
    {
      "Name" = "BastionHost"
    }
  )
  public_subnets_tags = merge(
    var.common_tags,
    {
      "Type"                                          = "public"
      "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
      "kubernetes.io/role/elb"                        = "1"

    }
  )
  public_subnetA_tags = merge(
    local.public_subnets_tags,
    {
      "Name" = "EKS Public Subnet A"
    }
  )
  public_subnetB_tags = merge(
    local.public_subnets_tags,
    {
      "Name" = "EKS Public Subnet B"
    }
  )
  public_subnetC_tags = merge(
    local.public_subnets_tags,
    {
      "Name" = "EKS Public Subnet C"
    }
  )


  workers_subnets_tags = merge(
    var.common_tags,
    {
      "Type"                                          = "private"
      "Name"                                          = "EKS Workers Private Subnet"
      "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
      "kubernetes.io/role/elb"                        = "1"

    }
  )
  workers_subnetsA_tags = merge(
    local.workers_subnets_tags,
    {
      "Name" = "EKS Workers Private Subnet A"
    }
  )
  workers_subnetsB_tags = merge(
    local.workers_subnets_tags,
    {
      "Name" = "EKS Workers Private Subnet B"
    }
  )
  workers_subnetsC_tags = merge(
    local.workers_subnets_tags,
    {
      "Name" = "EKS Workers Private Subnet C"
    }
  )

  database_subnetsA_tags = merge(
    var.common_tags,
    {
      "Type" = "private"
      "Name" = "DatabaseSubnetsA"

    }
  )
  database_subnetsB_tags = merge(
    var.common_tags,
    {
      "Type" = "private"
      "Name" = "DatabaseSubnetsB"

    }
  )
  database_subnetsC_tags = merge(
    var.common_tags,
    {
      "Type" = "private"
      "Name" = "DatabaseSubnetsC"

    }
  )


}
