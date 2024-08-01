data "aws_ami" "linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ami-0e872aee57663ae2d"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "tls_private_key" "tls_connector" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "myKeyPair" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.tls_connector.public_key_openssh
}

resource "aws_instance" "BastionHost" {
  for_each               = local.public_ec2_instaces
  ami                    = data.aws_ami.linux2.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.myKeyPair.key_name
  vpc_security_group_ids = each.value.bastionSG
  subnet_id              = each.value.subnet_id


  tags = each.value.tags
}
resource "aws_instance" "AppHost" {
  for_each               = local.private_app_ec2_instaces
  ami                    = data.aws_ami.linux2.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.myKeyPair.key_name
  vpc_security_group_ids = each.value.AppSG
  subnet_id              = each.value.subnet_id


  tags = each.value.tags
}
