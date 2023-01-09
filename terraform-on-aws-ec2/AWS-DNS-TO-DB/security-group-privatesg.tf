resource "aws_security_group" "private_sg" {
  name        = "private_sg"
  description = "Allow HTTP and SSH inbound traffic VPC, egress ports are all open"
  vpc_id      = module.vpc.vpc_id

# DEfining ingress and egreess Rules
  ingress {
    description      = "Allow SSH from All"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [module.vpc.vpc_cidr_block]
  }
ingress {
    description      = "Allow HTTP from All"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [module.vpc.vpc_cidr_block]
  }

  ingress {
    description      = "Allow 8080"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = [module.vpc.vpc_cidr_block]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "Name" = "${local.environment}-private_securitygroup"
  }
}