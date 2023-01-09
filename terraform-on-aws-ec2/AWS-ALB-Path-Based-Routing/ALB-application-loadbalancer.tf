module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "${local.name}-alb"

  load_balancer_type = "application"

  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.loadbalancer_sg.id]

 
  target_groups = [local.alb_targets["1"],local.alb_targets["2"]]
    
  http_tcp_listeners = [local.alb_http_listeners["1"]]
  https_listeners = [local.alb_http_listeners["2"]]
   
  https_listener_rules = [
    {
      # rule 1 /app1* should go to app1
      https_listener_index = 0
      actions = [
        {
          type = "forward"
          target_group_index = 0
        }     
      ]

      conditions = [{
        path_patterns = ["/app1*"]
      }]
    },

    {
      # rule 2 /app2* should go to app2
      https_listener_index = 0
      actions = [
        {
          type = "forward"
          target_group_index = 1
        }     
      ]

      conditions = [{
        path_patterns = ["/app2*"]
      }]
    }
  ]

  tags = local.common_tags
}

