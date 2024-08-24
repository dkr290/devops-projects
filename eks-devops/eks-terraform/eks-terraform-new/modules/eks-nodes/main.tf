resource "aws_eks_node_group" "eks_ng" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = var.eks_nodegroup_role_arn
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
    ec2_ssh_key = var.nodepool_keypair
  }

  update_config {
    max_unavailable = var.update_max_unavailable
  }

  tags = var.tags
}

resource "tls_private_key" "tls_connector" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "nodepool_keypair" {
  key_name   = var.nodepool_keypair
  public_key = tls_private_key.tls_connector.public_key_openssh
}
resource "local_file" "private_key" {
  content         = tls_private_key.tls_connector.private_key_pem
  filename        = "${path.cwd}/${var.nodepool_keypair}.pem"
  file_permission = "0400"
}
