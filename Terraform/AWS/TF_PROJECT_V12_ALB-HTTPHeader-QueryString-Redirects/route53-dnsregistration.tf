# DNS Registration 
resource "aws_route53_record" "apps_dns" {
  zone_id = data.aws_route53_zone.mydomain.zone_id
  name    = "myapps101.devopswithkishore.tech"
  type    = "A"
  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}

# # APP1 DNS Registration 
# resource "aws_route53_record" "app1_dns" {
#   zone_id = data.aws_route53_zone.mydomain.zone_id
#   name    = var.app1_dns_name
#   type    = "A"
#   alias {
#     name                   = module.alb.lb_dns_name
#     zone_id                = module.alb.lb_zone_id
#     evaluate_target_health = true
#   }
# }


# # APP2 DNS Registration 
# resource "aws_route53_record" "app2_dns" {
#   zone_id = data.aws_route53_zone.mydomain.zone_id
#   name    = var.app2_dns_name
#   type    = "A"
#   alias {
#     name                   = module.alb.lb_dns_name
#     zone_id                = module.alb.lb_zone_id
#     evaluate_target_health = true
#   }
# }

## Testing Host Header - Redirect to External Site from ALB HTTPS Listener Rules
resource "aws_route53_record" "app1_dns" {
  zone_id = data.aws_route53_zone.mydomain.zone_id
  name    = "terraform-aks101.devopswithkishore.tech"
  type    = "A"
  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}
