module "ec2_public" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.3.0"
  # insert the 34 required variables here

  name = "${var.environment}-bastionhost"
  ami                    =  data.aws_ami.amz_linux2.id
  instance_type          = var.instance_type
  key_name               = var.inst_keypair
  monitoring             = false
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.public_bastion_sg.id]
  user_data = file("${path.module}/jumpbox-install.sh")
  

  tags = local.common_tags
}