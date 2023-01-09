
resource "aws_instance" "myec2vm" {
  ami                    = data.aws_ami.amz_linux2.id
  instance_type          = var.instance_type
  //instance_type = var.instance_type_list[0]
 // instance_type = var.instance_type_map["prod"]
  key_name               = var.inst_keypair
  user_data              = file("${path.module}/app1-install.sh")
  vpc_security_group_ids = [aws_security_group.vpc-ssh.id, aws_security_group.vpc-web.id]

  count =2 
  
  tags = {
    "Name" = "Count-Demo-${count.index}"
  }
}