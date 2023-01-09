module "elb" {
  source  = "terraform-aws-modules/elb/aws"
  version = "~> 3.0"
  name = "${local.name}-elb"
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.loadbalancer_sg.id]
  internal        = false

  listener = [
    {
      instance_port     = 80
      instance_protocol = "HTTP"
      lb_port           = 80
      lb_protocol       = "HTTP"
    },
    {
      instance_port     = 80
      instance_protocol = "HTTP"
      lb_port           = 81
      lb_protocol       = "HTTP"
    },
  
  
  ]

  health_check = {
    target              = "HTTP:80/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  

  // ELB attachments
  number_of_instances = length(local.multiple_instances)
  instances           = [for instance in module.ec2_private: instance.id]
  tags = local.common_tags
}