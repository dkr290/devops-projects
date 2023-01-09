resource "aws_security_group" "public_bastion_sg" {
  name        = "public_bastion_sg"
  description = "Allow SSH inbound traffic from everybody, egress ports are all open"
  vpc_id      = module.vpc.vpc_id

# DEfining ingress and egreess Rules
  ingress {
    description      = "Allow SSH from All"
    from_port        = 22
    to_port          = 22
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

  tags = local.bastion_tags
}