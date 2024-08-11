data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "achitecture"
    values = ["x86_64"]
  }

}
resource "tls_private_key" "tls_connector" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "myKeyPair" {
  key_name   = var.ssh_keypair
  public_key = tls_private_key.tls_connector.public_key_openssh
}
resource "local_file" "private_key" {
  content         = tls_private_key.tls_connector.private_key_pem
  filename        = "${path.cwd}/${ssh_keypair}.pem"
  file_permission = "0400"
}
resource "aws_instance" "BastionHost" {
  for_each               = var.public_subnets
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.bastion_instancew_type
  key_name               = aws_key_pair.myKeyPair.key_name
  vpc_security_group_ids = aws_security_group.BastionHost.id
  subnet_id              = each.value.subnet_id


  tags = each.value.tags
}
