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

   multiple_instances_app1 = {
    "app1-1" = {
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
   
    "app1-2" = {
      instance_type     = var.instance_type
      availability_zone = element(module.vpc.azs, 1)
      subnet_id         = element(module.vpc.private_subnets, 1)
    }
    #  "3" = {
    #   instance_type     = var.instance_type
    #   availability_zone = element(module.vpc.azs, 0)
    #   subnet_id         = element(module.vpc.private_subnets, 0)
    #  }
 }
 multiple_instances_app2 = {
    "app2-1" = {
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
   
    "app2-2" = {
      instance_type     = var.instance_type
      availability_zone = element(module.vpc.azs, 1)
      subnet_id         = element(module.vpc.private_subnets, 1)
    }
    #  "3" = {
    #   instance_type     = var.instance_type
    #   availability_zone = element(module.vpc.azs, 0)
    #   subnet_id         = element(module.vpc.private_subnets, 0)
    #  }
 }

 multiple_instances_app3 = {
    "app3-1" = {
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
   
    "app3-2" = {
      instance_type     = var.instance_type
      availability_zone = element(module.vpc.azs, 1)
      subnet_id         = element(module.vpc.private_subnets, 1)
    }
    #  "3" = {
    #   instance_type     = var.instance_type
    #   availability_zone = element(module.vpc.azs, 0)
    #   subnet_id         = element(module.vpc.private_subnets, 0)
    #  }
 }


alb_http_listeners = {
   "1" = {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
      },

      "2" = {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      action_type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Fixed responce for root context"
        status_code  = "200"
      }
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
        path                = "/app1/index.html"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      },
    
      protocol_version = "HTTP1"
      #Registerted targets needs to be provided here 
      targets = [ for i,  instance in module.ec2_private_app1: { "target_id" = instance.id, "port" = 80 } ]

      },        


  "2" = {
      name_prefix          = "app2-"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 15
        path                = "/app2/index.html"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      },
    
      protocol_version = "HTTP1"
      #Registerted targets needs to be provided here 
      targets = [ for i,  instance in module.ec2_private_app2: { "target_id" = instance.id, "port" = 80 } ]
      
      }


       "3" = {
      name_prefix          = "app3-"
      backend_protocol     = "HTTP"
      backend_port         = 8080
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 15
        path                = "/login"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      stickiness ={
        enabled = true
        cookie_duration = 86400
        type = "lb_cookie"
      }
    
      protocol_version = "HTTP1"
      #Registerted targets needs to be provided here 
      targets = [ for i,  instance in aws_instance.ec2-private-app3: { "target_id" = instance.id, "port" = 8080 } ]
    
       

      }
      
  }
  



}