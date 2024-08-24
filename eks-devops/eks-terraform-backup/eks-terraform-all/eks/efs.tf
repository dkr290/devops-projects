resource "aws_efs_file_system" "efs-test" {
  count            = var.create_efs ? 1 : 0
  creation_token   = "efs-test"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true

  tags = {
    Name = "efs-test"
  }
}
resource "aws_security_group" "efs" {
  count       = var.create_efs ? 1 : 0
  name_prefix = "efs-sg"
  vpc_id      = data.terraform_remote_state.eks_vpc.outputs.vpc_id


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group_rule" "allow_from_eks" {
  count                    = var.create_efs ? 1 : 0
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
  security_group_id        = aws_security_group.efs[0].id
}

resource "aws_efs_mount_target" "example" {
  count           = var.create_efs ? length(data.terraform_remote_state.eks_vpc.outputs.private_subnet_ids) : 0
  file_system_id  = aws_efs_file_system.efs-test[0].id
  subnet_id       = data.terraform_remote_state.eks_vpc.outputs.private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs[0].id]
}
