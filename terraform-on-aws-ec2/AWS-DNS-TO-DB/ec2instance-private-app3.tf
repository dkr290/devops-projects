resource "aws_instance" "ec2-private-app3" {
  for_each = local.multiple_instances_app3
 
  ami           = data.aws_ami.amz_linux2.id
  instance_type = each.value.instance_type
  key_name = var.inst_keypair
  subnet_id  =  each.value.subnet_id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  user_data = templatefile("app3-ums-install.tmpl",{rds_db_endpoint=aws_db_instance.rdsdb.address})
  tags = {
    "Name" = "${var.environment}-private-${each.key}"
  }

  depends_on = [
    module.vpc
  ]
}