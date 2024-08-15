resource "aws_eks_node_group" "eks_ng" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = var.subnet_ids #aws_subnet.example[*].id
  # if not provided will default to the EKS version 

  # Set the version directly using a conditional expression
  version = var.cluster_version != "" ? var.cluster_version : null

  ami_type       = var.ami_type
  capacity_type  = var.capacity_type
  instance_types = var.instance_types
  disk_size      = var.disk_size

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  remote_access {
    ec2_ssh_key = var.ec2_ssh_key
  }

  update_config {
    max_unavailable = var.update_max_unavailable
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly
  ]
  tags = var.tags
}
# Install EBS CSI driver
resource "aws_eks_addon" "addons" {
  for_each                    = { for addon in var.addons : addon.name => addon }
  cluster_name                = var.cluster_id
  addon_name                  = each.value.name
  addon_version               = each.value.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [resource.aws_eks_node_group.eks_ng]
}


