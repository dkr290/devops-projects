

resource "aws_instance" "myec2vm" {
  ami                    = data.aws_ami.amz_linux2.id
  instance_type          = var.instance_type
  //instance_type = var.instance_type_list[0]
 // instance_type = var.instance_type_map["prod"]
  key_name               = var.inst_keypair
  user_data              = file("${path.module}/app1-install.sh")
  vpc_security_group_ids = [aws_security_group.vpc-ssh.id, aws_security_group.vpc-web.id]


  for_each = toset(keys({for key,  item in data.aws_ec2_instance_type_offering.my_inst_type: 
    
    key => item.instance_type if length(item.instance_type) != 0}))
  availability_zone = each.key
  
  tags = {
    "Name" = "Count-Demo-${each.key}"
  }
}