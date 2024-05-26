resource "aws_efs_file_system" "efs-test" {
  creation_token   = "efs-test"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true

  tags = {
    Name = "efs-test"
  }
}
resource "aws_security_group" "efs" {
  name_prefix = "efs-sg"
  vpc_id      = aws_vpc.eks_vpc.id


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group_rule" "allow_from_eks" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
  security_group_id        = aws_security_group.efs.id
}

resource "aws_efs_mount_target" "example" {
  count           = length(aws_subnet.private[*].id)
  file_system_id  = aws_efs_file_system.efs-test.id
  subnet_id       = aws_subnet.private[count.index].id
  security_groups = [aws_security_group.efs.id]
}
