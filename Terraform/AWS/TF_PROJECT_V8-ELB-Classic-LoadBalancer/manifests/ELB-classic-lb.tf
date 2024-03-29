module "elb" {
  source  = "terraform-aws-modules/elb/aws"
  version = "~> 3.0.0"

  name = "${local.name}-myelb"

  subnets = [
    module.vpc.public_subnets[0],
    module.vpc.public_subnets[1]
  ]
  security_groups = [module.loadbalancer_sg.security_group_id]
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

  #   access_logs = {
  #     bucket = "my-access-logs-bucket"
  #   }

  // ELB attachments
  number_of_instances = var.private_instance_count
  instances           = [module.ec2_private["app_vm1"].id, module.ec2_private["app_vm2"].id]

  tags = local.common_tags
}
