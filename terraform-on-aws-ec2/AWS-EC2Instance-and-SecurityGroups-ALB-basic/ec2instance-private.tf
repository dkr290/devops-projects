resource "random_integer" "priority" {
  min = length(var.vpc_private_subnets) - length(var.vpc_private_subnets)
  max = length(var.vpc_private_subnets) - 1
 
}

module "ec2_private" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.3.0"
  # insert the 34 required variables here

 
  //for_each = toset(var.private_instance_count)
  for_each = local.multiple_instances
  name = "${var.environment}-private-${each.key}"

  ami                    =  data.aws_ami.amz_linux2.id
  instance_type          = each.value.instance_type
  key_name               = var.inst_keypair
  monitoring             = false
  subnet_id              =  each.value.subnet_id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  
  user_data = file("${path.module}/apache-install.sh")
  tags = local.common_tags


  depends_on = [
    module.vpc
  ]
}