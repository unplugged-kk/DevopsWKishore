# AWS Classic Load Balancer with Terraform

## S1: Introduction
- Create AWS Security Group module for ELB CLB Load Balancer
- Create AWS ELB Classic Load Balancer Terraform Module
- Define Outputs for Load Balancer
- Access and test
- [Terraform Module AWS ELB](https://registry.terraform.io/modules/terraform-aws-modules/elb/aws/latest) used

## S2: Copy all templates from previous section 
- Copy `manifests` folder from `TF_PROJECT_V7-EC2-Instance-and-SecurityGroups`
- securitygroup-loadbalancingsg.tf
- ELB-classic-lb-variables.tf
- ELB-classic-lb.tf
- ELB-classic-lb-outputs.tf

## S3: securitygroup-loadbalancingsg.tf
```t
# Security Group for Public Load Balancer

module "loadbalancer_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~>4.0.0"

  name        = "loadbalancer-sg"
  description = "Security Group with HTTP open for entire Internet (IPv4 CIDR), egress ports are all world open"
  vpc_id      = module.vpc.vpc_id
  # Ingress Rules & CIDR Blocks
  ingress_rules       = ["http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  # Egress Rule - all-all open
  egress_rules = ["all-all"]
  tags         = local.common_tags

  # Open to CIDRs blocks (rule or from_port+to_port+protocol+description)
  ingress_with_cidr_blocks = [
    {
      from_port   = 81
      to_port     = 81
      protocol    = 6
      description = "Allow Port 81 from internet"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}


```

## S4: AWS ELB Classic Load Balancer
### S4-01: ELB-classic-lb.tf
- [terraform-aws-modules/elb/aws](https://registry.terraform.io/modules/terraform-aws-modules/elb/aws/latest)
```t
# Terraform AWS Classic Load Balancer (ELB-CLB)
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

```

### S4-02: Outputs for ELB Classic Load Balancer
- [Refer Outputs from Example](https://registry.terraform.io/modules/terraform-aws-modules/elb/aws/latest/examples/complete)
- ELB-classic-lb-outputs.tf
```t
# Terraform AWS Classic Load Balancer (ELB-CLB) Outputs
output "elb_id" {
  description = "The name of the ELB"
  value       = module.elb.elb_id
}

output "elb_name" {
  description = "The name of the ELB"
  value       = module.elb.elb_name
}

output "elb_dns_name" {
  description = "The DNS name of the ELB"
  value       = module.elb.elb_dns_name
}

output "elb_instances" {
  description = "The list of instances in the ELB (if may be outdated, because instances are attached using elb_attachment resource)"
  value       = module.elb.elb_instances
}

output "elb_source_security_group_id" {
  description = "The ID of the security group that you can use as part of your inbound rules for your load balancer's back-end application instances"
  value       = module.elb.elb_source_security_group_id
}

output "elb_zone_id" {
  description = "The canonical hosted zone ID of the ELB (to be used in a Route 53 Alias record)"
  value       = module.elb.elb_zone_id
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

# Terraform Apply
terraform apply -auto-approve

# Verify
Observation: 
1. Verify EC2 Instances
2. Verify Load Balancer SG
3. Verify Load Balancer Instances are healthy
4. Access sample app using Load Balancer DNS Name
5. Access Sample app with port 81 using Load Balancer DNS Name, it should fail, because from loadbalancer_sg port 81 is not allowed from internet. 
# Example: from my environment
http://HR-stag-myelb-557211422.us-east-1.elb.amazonaws.com  - Will pass
http://HR-stag-myelb-557211422.us-east-1.elb.amazonaws.com:81  - will fail
```

## S6: Update securitygroup-loadbalancersg.tf 
```t
  # Security Group for Public Load Balancer
module "loadbalancer_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~>4.0.0"

  name        = "loadbalancer-sg"
  description = "Security Group with HTTP open for entire Internet (IPv4 CIDR), egress ports are all world open"
  vpc_id      = module.vpc.vpc_id
  # Ingress Rules & CIDR Blocks
  ingress_rules       = ["http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  # Egress Rule - all-all open
  egress_rules = ["all-all"]
  tags         = local.common_tags

  # Open to CIDRs blocks (rule or from_port+to_port+protocol+description)
  ingress_with_cidr_blocks = [
    {
      from_port   = 81
      to_port     = 81
      protocol    = 6
      description = "Allow Port 81 from internet"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}
 
```

## S7: Again Execute Terraform Commands
```t
# Terraform Plan
terraform plan

# Terraform Apply
terraform apply -auto-approve

# Verify
Observation: 
1) Verify loadbalancer-sg in AWS mgmt console
2) Access App using port 81 and test
http://HR-stag-myelb-557211422.us-east-1.elb.amazonaws.com:81  - should pass
```

## S8: Clean-Up
```t
# Terraform Destroy
terraform destroy -auto-approve

# Delete files
rm -rf .terraform*
rm -rf terraform.tfstate*
```