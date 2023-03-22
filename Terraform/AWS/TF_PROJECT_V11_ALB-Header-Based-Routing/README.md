---
title: AWS ALB Host Header based Routing using Terraform
description: Create AWS Application Load Balancer Host Header based Routing Rules usign Terraform
---

# AWS ALB Host Header based Routing using Terraform

## Pre-requisites
- You need a Registered Domain in AWS Route53 to implement this usecase
- Copy your `terraform-key.pem` file to `terraform-manifests/private-key` folder


## S1: Introduction
- Implement AWS ALB Host Header based Routing



## S2: Error Message realted AWS ACM Certificate Limit
- Review the AWS Support Case ID 8245155801 to demonstrate the issue and resolution from AWS
- Understand about how to submit the case related to Limit Increase for ACM Certificates.
- It will take 2 to 3 days to increase the limit and resolve the issue from AWS Side so if you want to ensure that before you hit the limit, if you want to increase you can submit the ticket well in advance.
```t
Error: Error requesting certificate: LimitExceededException: Error: you have reached your limit of 20 certificates in the last year.

  on .terraform/modules/acm/main.tf line 11, in resource "aws_acm_certificate" "this":
  11: resource "aws_acm_certificate" "this" {
```

## S3: Our Options to Continue
- **Option-1:** Submit the ticket to AWS and wait till they update the ACM certificate limit


## S4: ALB-application-loadbalancer-variables.tf
- We will be using these variables in two places
  - ALB-application-loadbalancer.tf
  - route53-dnsregistration.tf
- If we are using the values in more than one place its good to variablize that value  
```t
# App1 DNS Name
variable "app1_dns_name" {
  description = "App1 DNS Name"
}

# App2 DNS Name
variable "app2_dns_name" {
  description = "App2 DNS Name"
}
```
## S5: loadbalancer.auto.tfvars
```t
# AWS Load Balancer Variables
app1_dns_name = "app1.devopswithkishore.tech"
app2_dns_name = "app2.devopswithkishore.tech"
```

## S6: ALB-application-loadbalancer.tf
### S6-01: HTTPS Listener Rule-1
```t
      # Rule-1: app1.devopsincloud.com should go to App1 EC2 Instances
    {
      https_listener_index = 0
      actions = [
        {
          type               = "forward"
          target_group_index = 0
        }
      ]
      conditions = [{
        # path_patterns = ["/app1*"]
        host_headers = [var.app1_dns_name]
      }]
    },
```
### S6-02: HTTPS Listener Rule-2
```t
      # Rule-2: app2.devopsincloud.com should go to App2 EC2 Instances     
    {
      https_listener_index = 0
      actions = [
        {
          type               = "forward"
          target_group_index = 1
        }
      ]
      conditions = [{
        # path_patterns = ["/app2*"]
        host_headers = [var.app2_dns_name]
      }]
    },
```

## S7: route53-dnsregistration.tf
### S7-01: App1 DNS
```t
# DNS Registration 
resource "aws_route53_record" "apps_dns" {
  zone_id = data.aws_route53_zone.mydomain.zone_id
  name    = "apps.devopswithkishore.tech"
  type    = "A"
  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}

# DNS Registration 
# APP1 DNS Registration 
resource "aws_route53_record" "app1_dns" {
  zone_id = data.aws_route53_zone.mydomain.zone_id
  name    = var.app1_dns_name
  type    = "A"
  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}
```
### S7-02: App2 DNS
```t
# APP2 DNS Registration 
resource "aws_route53_record" "app2_dns" {
  zone_id = data.aws_route53_zone.mydomain.zone_id
  name    = var.app2_dns_name
  type    = "A"
  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}
```

## S8: Execute Terraform Commands
```t
# Terraform Initialize
terraform init

# Terraform Validate
terraform validate

# Terraform Plan
terraform plan

# Terraform Apply
terraform apply -auto-approve

# Verify
Observation: 
1. Verify EC2 Instances for App1
2. Verify EC2 Instances for App2
3. Verify Load Balancer SG - Primarily SSL 443 Rule
4. Verify ALB Listener - HTTP:80 - Should contain a redirect from HTTP to HTTPS
5. Verify ALB Listener - HTTPS:443 - Should contain 3 rules 
5.1 Host Header app1.devopswithkishore.tech to app1-tg 
5.2 Host Header app2.devopswithkishore.tech toto app2-tg 
5.3 Fixed Response: any other errors or any other IP or valid DNS to this LB
6. Verify ALB Target Groups App1 and App2, Targets (should be healthy) 
5. Verify SSL Certificate (Certificate Manager)
6. Verify Route53 DNS Record

# Test (Domain will be different for you based on your registered domain)
# Note: All the below URLS shoud redirect from HTTP to HTTPS
# App1
1. App1 Landing Page index.html at Root Context of App1: http://app1.devopswithkishore.tech
2. App1 /app1/index.html: http://app1.devopswithkishore.tech/app1/index.html
3. App1 /app1/metadata.html: http://app1.devopswithkishore.tech/app1/metadata.html
4. Failure Case: Access App2 Directory from App1 DNS: http://app1.devopswithkishore.tech/app2/index.html - Should return Directory not found 404

# App2
1. App2 Landing Page index.html at Root Context of App1: http://app2.devopswithkishore.tech
2. App1 /app2/index.html: http://app1.devopswithkishore.tech/app2/index.html
3. App1 /app2/metadata.html: http://app1.devopswithkishore.tech/app2/metadata.html
4. Failure Case: Access App2 Directory from App1 DNS: http://app2.devopswithkishore.tech/app1/index.html - Should return Directory not found 404
```

## S9: Clean-Up
```t
# Terraform Destroy
terraform destroy -auto-approve

# Delete files
rm -rf .terraform*
rm -rf terraform.tfstate*
```