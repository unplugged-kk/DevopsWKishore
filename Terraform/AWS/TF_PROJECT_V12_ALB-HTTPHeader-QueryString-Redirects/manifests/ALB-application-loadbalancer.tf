# Terraform AWS Application Load Balancer (ALB)
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "7.0.0"

  name               = "${local.name}-alb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets = [
    module.vpc.public_subnets[0],
    module.vpc.public_subnets[1]
  ]
  security_groups = [module.loadbalancer_sg.security_group_id]
  # Listeners
  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]
  # Target Groups
  target_groups = [
    # App1 Target Group - TG Index = 0
    {
      name_prefix          = "app1-"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/app1/index.html"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      protocol_version = "HTTP1"
      # App1 Target Group - Targets
      targets = {
        my_app1_vm1 = {
          target_id = module.ec2_private_app1["vm1"].id
          port      = 80
        },
        my_app1_vm2 = {
          target_id = module.ec2_private_app1["vm2"].id
          port      = 80
        }
      }
      tags = local.common_tags # Target Group Tags
    },

    # App2 Target Group - TG Index = 1
    {
      name_prefix          = "app2-"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/app2/index.html"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      protocol_version = "HTTP1"
      # App2 Target Group - Targets
      targets = {
        my_app2_vm1 = {
          target_id = module.ec2_private_app2["vm1"].id
          port      = 80
        },
        my_app2_vm2 = {
          target_id = module.ec2_private_app2["vm2"].id
          port      = 80
        }
      }
      tags = local.common_tags # Target Group Tags
    }
  ]
  # HTTPS Listener
  https_listeners = [
    # HTTPS Listener Index = 0 for HTTPS 443
    {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.acm.acm_certificate_arn
      action_type     = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Fixed Static message - for Root Context"
        status_code  = "200"
      }
    },
  ]
  # HTTPS Listener Rules
  https_listener_rules = [
    # Rule-1: custom-header=my-app-1 should go to App1 EC2 Instances
    {
      https_listener_index = 0
      priority             = 1
      actions = [
        {
          type               = "forward"
          target_group_index = 0
        }
      ]
      conditions = [{
        #path_patterns = ["/app1*"]
        #host_headers = [var.app1_dns_name]
        http_headers = [{
          http_header_name = "custom-header"
          values           = ["app-1", "app1", "my-app-1"]
        }]
      }]
    },
    # Rule-2: custom-header=my-app-2 should go to App2 EC2 Instances    
    {
      https_listener_index = 0
      priority             = 2
      actions = [
        {
          type               = "forward"
          target_group_index = 1
        }
      ]
      conditions = [{
        #path_patterns = ["/app2*"] 
        #host_headers = [var.app2_dns_name]
        http_headers = [{
          http_header_name = "custom-header"
          values           = ["app-2", "app2", "my-app-2"]
        }]
      }]
    },
    # Rule-3: When Query-String, website=terraform-eks redirect to https://learnk8s.io/terraform-eks
    {
      https_listener_index = 0
      priority             = 3
      actions = [{
        type        = "redirect"
        status_code = "HTTP_302"
        host        = "learnk8s.io"
        path        = "/terraform-eks/"
        query       = ""
        protocol    = "HTTPS"
      }]
      conditions = [{
        query_strings = [{
          key   = "website"
          value = "terraform-eks"
        }]
      }]
    },
    # Rule-4: When Host Header = terraform-aks.devopswithkishore.tech, redirect to https://learnk8s.io/terraform-aks
    {
      https_listener_index = 0
      priority             = 4
      actions = [{
        type        = "redirect"
        status_code = "HTTP_302"
        host        = "learnk8s.io"
        path        = "/terraform-aks/"
        query       = ""
        protocol    = "HTTPS"
      }]
      conditions = [{
        host_headers = ["terraform-aks101.devopswithkishore.tech"]
      }]
    },
  ]
  tags = local.common_tags # ALB Tags
}
