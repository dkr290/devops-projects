resource "aws_security_group" "BastionSG" {
  name        = "BastionSG"
  description = "Allow ssh"
  vpc_id      = var.vpc_id

  tags = {
    Name = "BastionSG"
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "AppSG" {
  name        = "AppSG"
  description = "Allow from BastionSG"
  vpc_id      = var.vpc_id

  tags = {
    Name = "AppSG"
  }

  ingress {
    from_port       = "22"
    to_port         = "22"
    protocol        = "TCP"
    security_groups = [aws_security_group.BastionSG.id]
    description     = "allow ssh traffic from bastion sg"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
