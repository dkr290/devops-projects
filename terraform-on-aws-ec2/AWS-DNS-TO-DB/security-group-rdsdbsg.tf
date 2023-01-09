resource "aws_security_group" "rdsdb-sg" {
  name        = "rdsdb_sg"
  description = "Allow SSH inbound traffic from everybody, egress ports are all open"
  vpc_id      = module.vpc.vpc_id

# DEfining ingress and egreess Rules
  ingress {
    description      = "MySQL access from within VPC"
    from_port        = 3306
    to_port          = 3306
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

  tags = local.bastion_tags
}