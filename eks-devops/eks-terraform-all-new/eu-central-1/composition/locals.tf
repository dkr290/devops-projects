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
      "Name"                                          = "EKS Public Subnet"
      "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
      "kubernetes.io/role/elb"                        = "1"

    }
  )
}
