resource "aws_security_group" "loadbalancer_sg" {
  name        = "loadbalancer_sg"
  description = "Allow HTTP open from Internet"
  vpc_id      = module.vpc.vpc_id

# Defining ingress and egreess Rules

ingress {
    description      = "Allow HTTP from All"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "Allow HTTPS from All"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow 81 from All"
    from_port        = 81
    to_port          = 81
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "Name" = "${local.environment}-loadbalancer_securitygroup"
  }
}