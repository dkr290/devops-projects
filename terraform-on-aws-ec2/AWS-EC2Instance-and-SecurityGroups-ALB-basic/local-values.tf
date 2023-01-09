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

alb_http_listeners = {
   "1" = {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
   }
  

}

alb_targets = {
  "1" = {
      name_prefix          = "app1-"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 15
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      protocol_version = "HTTP1"
      #Registerted targets needs to be provided here 
      targets = [ for i,  instance in module.ec2_private: { "target_id" = instance.id, "port" = 80 } ]
      }
    }




}