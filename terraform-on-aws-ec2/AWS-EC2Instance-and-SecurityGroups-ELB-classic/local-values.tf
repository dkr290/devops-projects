locals {
  owners = var.business_divsion
  environment = var.environment
  name = "${var.business_divsion}-${var.environment}"

  common_tags = {
      owners = local.owners      
      environment = local.environment
  }

  bastion_tags = {
     environment = local.environment
     Name = "${var.environment}-bastion_securitygroup"
  }

   multiple_instances = {
    "1" = {
      instance_type     = var.instance_type
      availability_zone = element(module.vpc.azs, 0)
      subnet_id         = element(module.vpc.private_subnets, 0)
      root_block_device = [
        {
          encrypted   = true
          volume_type = "gp2"
          volume_size = 10
          tags = {
            Name = "my-root-block"
          }
        }
      ]
    }
   
    "2" = {
      instance_type     = var.instance_type
      availability_zone = element(module.vpc.azs, 1)
      subnet_id         = element(module.vpc.private_subnets, 1)
    }
     "3" = {
      instance_type     = var.instance_type
      availability_zone = element(module.vpc.azs, 0)
      subnet_id         = element(module.vpc.private_subnets, 0)
    }
 }





}