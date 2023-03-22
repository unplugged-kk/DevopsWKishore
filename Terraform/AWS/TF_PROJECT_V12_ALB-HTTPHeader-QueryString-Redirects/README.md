---
title: AWS ALB Different Listener Rules for Routing
description: Create AWS Application Load Balancer Custom HTTP Header, 302 Redirects with Query String and Host Headers
---
# AWS ALB Query String, Host Header Redirects and Custom Header Routing

## Pre-requisites
- You need a Registered Domain in AWS Route53 to implement this usecase
- Copy your `terraform-key.pem` file to `terraform-manifests/private-key` folder

## S1: Introduction
- We are going to implement four AWS ALB Application HTTPS Listener Rules
- Rule-1 and Rule-2 will outline the Custom HTTP Header based Routing
- Rule-3 and Rule-4 will outline the HTTP Redirect using Query String and Host Header based rules
- **Rule-1:** custom-header=my-app-1 should go to App1 EC2 Instances
- **Rule-2:** custom-header=my-app-2 should go to App2 EC2 Instances   
- **Rule-3:** When Query-String, website=terraform-eks redirect to https://learnk8s.io/terraform-eks
- **Rule-4:** When Host Header = terraform-aks.kishorekumar.online, redirect to https://learnk8s.io/terraform-aks

- Understand about Priority feature for Rules `priority = 2`


## S2: ALB-application-loadbalancer.tf
- Define different HTTPS Listener Rules for ALB Load Balancer
### S2-01: Rule-1: Custom Header Rule for App-1
- Rule-1: custom-header=my-app-1 should go to App1 EC2 Instances
```t
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
```
### S2-02: Rule-2: Custom Header Rule for App-2
- Rule-2: custom-header=my-app-2 should go to App2 EC2 Instances    
```t
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
```
### S2-03: Rule-3: Query String Redirect
- Rule-3: When Query-String, website=terraform-eks redirect to https://learnk8s.io/terraform-eks
```t
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
```
### S2-04: Rule-4: Host Header Redirect
- Rule-4: When Host Header = terraform-aks.kishorekumar.online, redirect to https://learnk8s.io/terraform-aks 
```t
  # Rule-4: When Host Header = terraform-aks.kishorekumar.online, redirect to https://learnk8s.io/terraform-aks
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
        host_headers = ["terraform-aks101.kishorekumar.online"]
      }]
    },
```

## S3: route53-dnsregistration.tf
```t
# DNS Registration 
resource "aws_route53_record" "apps_dns" {
  zone_id = data.aws_route53_zone.mydomain.zone_id
  name    = "myapps101.kishorekumar.online"
  type    = "A"
  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}

## Testing Host Header - Redirect to External Site from ALB HTTPS Listener Rules
resource "aws_route53_record" "app1_dns" {
  zone_id = data.aws_route53_zone.mydomain.zone_id
  name    = "terraform-aks101.kishorekumar.online"
  type    = "A"
  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}

```
## S4: Terraform ALB Module v7.0.0 Changes
### S4-01: ALB-application-loadbalancer.tf
```t
# Before
  version = "5.16.0"

# After
   version = "7.0.0"
```
### S4-02: ALB-application-loadbalancer-outputs.tf
- [ALB Outpus Reference](https://github.com/terraform-aws-modules/terraform-aws-alb/blob/v6.0.0/examples/complete-alb/outputs.tf)
- Update `ALB-application-loadbalancer-outputs.tf` with latest outputs
```t
output "lb_id" {
  description = "The ID and ARN of the load balancer we created."
  value       = module.alb.lb_id
}

output "lb_arn" {
  description = "The ID and ARN of the load balancer we created."
  value       = module.alb.lb_arn
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = module.alb.lb_dns_name
}

output "lb_arn_suffix" {
  description = "ARN suffix of our load balancer - can be used with CloudWatch."
  value       = module.alb.lb_arn_suffix
}

output "lb_zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records."
  value       = module.alb.lb_zone_id
}

output "http_tcp_listener_arns" {
  description = "The ARN of the TCP and HTTP load balancer listeners created."
  value       = module.alb.http_tcp_listener_arns
}

output "http_tcp_listener_ids" {
  description = "The IDs of the TCP and HTTP load balancer listeners created."
  value       = module.alb.http_tcp_listener_ids
}

output "https_listener_arns" {
  description = "The ARNs of the HTTPS load balancer listeners created."
  value       = module.alb.https_listener_arns
}

output "https_listener_ids" {
  description = "The IDs of the load balancer listeners created."
  value       = module.alb.https_listener_ids
}

output "target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group."
  value       = module.alb.target_group_arns
}

output "target_group_arn_suffixes" {
  description = "ARN suffixes of our target groups - can be used with CloudWatch."
  value       = module.alb.target_group_arn_suffixes
}

output "target_group_names" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group."
  value       = module.alb.target_group_names
}

output "target_group_attachments" {
  description = "ARNs of the target group attachment IDs."
  value       = module.alb.target_group_attachments
}

```

### S4-03: route53-dnsregistration.tf
```t
# DNS Registration 
resource "aws_route53_record" "apps_dns" {
  zone_id = data.aws_route53_zone.mydomain.zone_id
  name    = "myapps101.kishorekumar.online"
  type    = "A"
  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}


## Testing Host Header - Redirect to External Site from ALB HTTPS Listener Rules
resource "aws_route53_record" "app1_dns" {
  zone_id = data.aws_route53_zone.mydomain.zone_id
  name    = "terraform-aks101.kishorekumar.online"
  type    = "A"
  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}
    
```


## S5: Execute Terraform Commands
```t
# Terraform Initialize
terraform init

# Terraform Validate
terraform validate

# Terraform Plan
terraform plan

# Terrform Apply
terraform apply -auto-approve
```

## S6: Verify HTTP Header Based Routing (Rule-1 and Rule-2)
- Rest Clinets we can use
- https://restninja.io/ 
- https://www.webtools.services/online-rest-api-client
- https://reqbin.com/
```t
# Verify Rule-1 and Rule-2
https://myapps.kishorekumar.online
custom-header = my-app-1  - Should get the page from App1 
custom-header = my-app-2  - Should get the page from App2
```

## S7: Verify Rule-3 
- When Query-String, website=aws-eks redirect to https://learnk8s.io/terraform-eks/
```t
# Verify Rule-3
https://myapps.kishorekumar.online/?website=aws-eks 
Observation: 
1. Should Redirect to https://learnk8s.io/terraform-eks/
```

## S8: Verify Rule-4
-  When Host Header = azure-aks.kishorekumar.online, redirect to https://learnk8s.io/terraform-aks/
```t
# Verify Rule-4
http://azure-aks.kishorekumar.online
Observation: 
1. Should redirect to https://learnk8s.io/terraform-aks/
```

## S9: Clean-Up
```t
# Destroy Resources
terraform destroy -auto-approve

# Delete Files
rm -rf .terraform*
rm -rf terraform.tfstate
```


## References
- [Terraform AWS ALB](https://github.com/terraform-aws-modules/terraform-aws-alb)