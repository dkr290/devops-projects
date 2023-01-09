module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "${local.name}-alb"

  load_balancer_type = "application"

  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.loadbalancer_sg.id]

 
  target_groups = [local.alb_targets["1"]]
    
  http_tcp_listeners = [local.alb_http_listeners["1"]]
  

  tags = local.common_tags
}

