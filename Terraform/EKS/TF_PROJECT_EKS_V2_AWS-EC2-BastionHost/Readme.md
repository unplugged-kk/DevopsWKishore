---
title: AWS EC2 Bastion Host in Public Subnet
description: Create AWS EC2 Bastion Host used to connect to EKS Node Group EC2 VMs
---

## S1: Introduction 
1. For VPC switch Availability Zones from Static to Dynamic using Datasource `aws_availability_zones`
2. Create EC2 Key pair that will be used for connecting to Bastion Host and EKS Node Group EC2 VM Instances
3. EC2 Bastion Host - [Terraform Input Variables](https://www.terraform.io/docs/language/values/variables.html)
4. EC2 Bastion Host - [AWS Security Group Terraform Module](https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest)
5. EC2 Bastion Host - [AWS AMI Datasource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) (Dynamically lookup the latest Amazon2 Linux AMI)
6. EC2 Bastion Host - [AWS EC2 Instance Terraform Module](https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest)
7. EC2 Bastion Host - [Terraform Resource AWS EC2 Elastic IP](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)
8. EC2 Bastion Host - [Terraform Provisioners](https://www.terraform.io/docs/language/resources/provisioners/syntax.html)
   - [File provisioner](https://www.terraform.io/docs/language/resources/provisioners/file.html)
   - [remote-exec provisioner](https://www.terraform.io/docs/language/resources/provisioners/local-exec.html)
   - [local-exec provisioner](https://www.terraform.io/docs/language/resources/provisioners/remote-exec.html)
9. EC2 Bastion Host - [Output Values](https://www.terraform.io/docs/language/values/outputs.html)
10. EC2 Bastion Host - ec2bastion.auto.tfvars
11. EKS Input Variables 
12. EKS [Local Values](https://www.terraform.io/docs/language/values/locals.html)
13. EKS Tags in VPC for Public and Private Subnets
14. Execute Terraform Commands and Test
15. Elastic IP - [depends_on Meta Argument](https://www.terraform.io/docs/language/meta-arguments/depends_on.html)

## S1: For VPC switch Availability Zones from Static to Dynamic
- [Datasource: aws_availability_zones](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones)
- **File Name:** `c3-02-vpc-module.tf` for changes 1 and 2
```t
# Change-1: Add Datasource named aws_availability_zones
# AWS Availability Zones Datasource  
data "aws_availability_zones" "available" {
}

## S2: Create EC2 Key pair and save it
- Go to Services -> EC2 -> Network & Security -> Key Pairs -> Create Key Pair
- **Name:** eks-terraform-key
- **Key Pair Type:** RSA (leave to defaults)
- **Private key file format:** .pem
- Click on **Create key pair**
- COPY the downloaded key pair to `terraform-manifests/private-key` folder
- Provide permissions as `chmod 400 keypair-name`
```t
# Provider Permissions to EC2 Key Pair
cd terraform-manifests/private-key
chmod 400 eks-terraform-key.pem
```
## S3: ec2bastion-instance-variables.tf
```t
# AWS EC2 Instance Terraform Variables

variable "instance_type" {
  description = "Instance type for bastion"
  type        = string
  default     = "t2.micro"
}

variable "key_pair" {
  description = "ec2 instance key pair"
  type        = string
  default     = "eks-terraform-key"
}

variable "monitoring" {
  type    = bool
  default = true
}

```
## S4: ec2bastion-instance-sg.tf
```t
# AWS EC2 Security Group Terraform Module
# Security Group for Public Bastion Host
module "public_bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.5.0"

  name        = "${local.name}-public-bastion-sg"
  description = "Security Group with SSH port open for everybody (IPv4 CIDR), egress ports are all world open"
  vpc_id      = module.vpc.vpc_id
  # Ingress Rules & CIDR Blocks
  ingress_rules       = ["ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  # Egress Rule - all-all open
  egress_rules = ["all-all"]
  tags         = local.common_tags
}
```

## S5: ami-datasource.tf
```t
# Get latest AMI ID for Amazon Linux2 OS
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name = "name"
    values = [ "amzn2-ami-hvm-*-gp2" ]
  }
  filter {
    name = "root-device-type"
    values = [ "ebs" ]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
  filter {
    name = "architecture"
    values = [ "x86_64" ]
  }
}
```

## S6: ec2bastion-instance.tf
```t
# AWS EC2 Instance Terraform Module
# Bastion Host - EC2 Instance that will be created in VPC Public Subnet
module "ec2_bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "${local.name}-BastionHost"

  ami                    = data.aws_ami.amzlinux2.id
  instance_type          = var.instance_type
  key_name               = var.key_pair
  monitoring             = var.monitoring
  vpc_security_group_ids = [module.public_bastion_sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]

  tags = local.common_tags
}
```

## S7: ec2bastion-elasticip.tf
```t
# Create Elastic IP for Bastion Host
# Resource - depends_on Meta-Argument
resource "aws_eip" "ec2_bastion_eip" {
  vpc        = true
  instance   = module.ec2_bastion.id
  depends_on = [module.vpc, module.ec2_bastion]
  tags       = local.common_tags
}

## ec2_bastion_public_ip
output "ec2_bastion_eip" {
  description = "Elastic IP associated to the Bastion Host"
  value       = aws_eip.ec2_bastion_eip.public_ip
}

```
## S8: ec2bastion-provisioners.tf
```t
resource "null_resource" "copy_ec2_keys" {
  depends_on = [module.ec2_bastion]
  # Connection Block for Provisioners to connect to EC2 Instance
  connection {
    type        = "ssh"
    host        = aws_eip.ec2_bastion_eip.public_ip
    user        = "ec2-user"
    password    = ""
    private_key = file("private-key/eks-terraform-key.pem")
  }

  ## File Provisioner: Copies the terraform-key.pem file to /tmp/terraform-key.pem
  provisioner "file" {
    source      = "private-key/eks-terraform-key.pem"
    destination = "/tmp/eks-terraform-key.pem"
  }
  ## Remote Exec Provisioner: Using remote-exec provisioner fix the private key permissions on Bastion Host
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 /tmp/eks-terraform-key.pem"
    ]
  }
  ## Local Exec Provisioner:  local-exec provisioner (Creation-Time Provisioner - Triggered during Create Resource)
  provisioner "local-exec" {
    command     = "echo VPC created on `date` and VPC ID: ${module.vpc.vpc_id} >> creation-time-vpc-id.txt"
    working_dir = "local-exec-output-files/"
    #on_failure = continue
  }

}

```

## S9: ec2bastion.auto.tfvars
```t
instance_type = "t3.micro"
key_pair      = "eks-terraform-key"

```

## S10: ec2bastion-outputs.tf
```t
## ec2_bastion_public_instance_ids
output "ec2_bastion_public_instance_ids" {
  description = "List of IDs of instances"
  value       = module.ec2_bastion.id
}


```

## S11: eks-variables.tf
```t
# EKS Cluster Input Variables
variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
  type        = string
  default     = "kk-eks"
}

```

## S12: eks.auto.tfvars
```t
cluster_name = "kishore-eks"
```

## S13: locals.tf
```t
locals {
  owners      = var.business_divsion
  environment = var.environment
  name        = "${var.business_divsion}-${var.environment}"

  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
} 
```

## S13: Execute Terraform Commands
```t
# Terraform Initialize
terraform init

# Terraform Validate
terraform validate

# Terraform plan
terraform plan

# Terraform Apply
terraform apply -auto-approve
```

## S14: Verify the following
1. Verify VPC Tags
2. Verify Bastion EC2 Instance 
3. Verify Bastion EC2 Instance Security Group
4. Connect to Bastion EC2 Instnace
```t
# Connect to Bastion EC2 Instance
ssh -i private-key/eks-terraform-key.pem ec2-user@<Elastic-IP-Bastion-Host>
sudo su -

# Verify File and Remote Exec Provisioners moved the EKS PEM file
cd /tmp
ls -lrta
Observation: We should find the file named "eks-terraform-key.pem" moved from our local desktop to Bastion EC2 Instance "/tmp" folder
```

## S15: Clean-Up
```t
# Delete Resources
terraform destroy -auto-approve
terraform apply -destroy -auto-approve

# Delete Files
rm -rf .terraform* terraform.tfstate*
```