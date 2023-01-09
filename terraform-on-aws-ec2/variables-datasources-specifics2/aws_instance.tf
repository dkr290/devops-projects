
data "aws_availability_zones" "myazones" {
  all_availability_zones = true

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

resource "aws_instance" "myec2vm" {
  ami                    = data.aws_ami.amz_linux2.id
  instance_type          = var.instance_type
  //instance_type = var.instance_type_list[0]
 // instance_type = var.instance_type_map["prod"]
  key_name               = var.inst_keypair
  user_data              = file("${path.module}/app1-install.sh")
  vpc_security_group_ids = [aws_security_group.vpc-ssh.id, aws_security_group.vpc-web.id]

  for_each = toset(data.aws_availability_zones.myazones.names)
  availability_zone = each.key
  
  tags = {
    "Name" = "Count-Demo-${each.value}"
  }
}