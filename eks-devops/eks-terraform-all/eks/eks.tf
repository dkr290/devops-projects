
# Create EKS cluster
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = concat(
      data.terraform_remote_state.eks_vpc.outputs.public_subnet_ids,
    data.terraform_remote_state.eks_vpc.outputs.private_subnet_ids)
  }
  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = var.kubernetes_network_config_cidr
  }


  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_policy,
    aws_iam_role.eks_cluster_role,
  ]
}


# # Create security group for EKS cluster
# resource "aws_security_group" "cluster_sg" {
#   name_prefix = "cluster-sg"
#   vpc_id      = aws_vpc.eks_vpc.id
#
#   ingress {
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#     cidr_blocks     = ["0.0.0.0/0"]
#   }
#
#   egress {
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#     cidr_blocks     = ["0.0.0.0/0"]
#   }
# }

# Configure OIDC provider
data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}
# Install EBS CSI driver
resource "aws_eks_addon" "addons" {
  for_each          = { for addon in var.addons : addon.name => addon }
  cluster_name      = aws_eks_cluster.eks.id
  addon_name        = each.value.name
  addon_version     = each.value.version
  resolve_conflicts = "OVERWRITE"
  depends_on        = [resource.aws_eks_node_group.workers1]
}

#aws eks update-kubeconfig --region <region> --name <cluster_name>
