
# Create worker node group
resource "aws_eks_node_group" "workers1" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "workers"
  node_role_arn   = aws_iam_role.eks_node_role.arn

  subnet_ids = data.terraform_remote_state.eks_vpc.outputs.private_subnet_ids

  capacity_type  = "ON_DEMAND"
  instance_types = ["t2.small"]

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }


  update_config {
    max_unavailable = 1
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_read_only,
  ]
}
resource "aws_eks_node_group" "workers2" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "spot-workers"
  node_role_arn   = aws_iam_role.eks_node_role.arn

  subnet_ids = data.terraform_remote_state.eks_vpc.outputs.private_subnet_ids


  capacity_type  = "SPOT"
  instance_types = ["t2.small", "t2.medium"]

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_read_only,
  ]

}

# Create security group for worker nodes
resource "aws_security_group" "worker_node_sg" {
  name_prefix = "worker-node-sg"
  vpc_id      = data.terraform_remote_state.eks_vpc.outputs.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
