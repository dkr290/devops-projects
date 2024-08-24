resource "aws_security_group" "BastionSG" {
  name        = "BastionSG"
  description = local.bastionhost_description
  vpc_id      = var.vpc_id

  tags = {
    Name = "BastionSG"
  }

  ingress {
    from_port   = var.ingress_from_port
    to_port     = var.ingress_to_port
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

