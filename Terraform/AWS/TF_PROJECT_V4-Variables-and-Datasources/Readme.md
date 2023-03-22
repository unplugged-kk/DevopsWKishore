# Terraform Variables and Datasources

## S0: Pre-requisite Note
- Create a `terraform-key` in AWS EC2 Key pairs which we will reference in our EC2 Instance

## S1: Introduction
### Terraform Concepts
- Terraform Input Variables
- Terraform Datasources
- Terraform Output Values




## S2: variables.tf - Define Input Variables in Terraform
- [Terraform Input Variables](https://www.terraform.io/docs/language/values/variables.html)
- [Terraform Input Variable Usage - 10 different types](https://github.com/stacksimplify/hashicorp-certified-terraform-associate/tree/main/05-Terraform-Variables/05-01-Terraform-Input-Variables)
```t
# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type = string
  default = "us-east-1"  
}

# AWS EC2 Instance Type
variable "instance_type" {
  description = "EC2 Instance Type"
  type = string
  default = "t3.micro"  
}

# AWS EC2 Instance Key Pair
variable "instance_keypair" {
  description = "AWS EC2 Key pair that need to be associated with EC2 Instance"
  type = string
  default = "terraform-key"
}
```
- Reference the variables in respective `.tf`fies
```t
# versions.tf
region  = var.aws_region
```

## S3: security_groups.tf - Define Security Group Resources in Terraform
- [Resource: aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)
```t
# Create Security Group - SSH Traffic
#Allow HTTPS


resource "aws_security_group" "vpc_web" {
  name        = "vpc_web"
  description = "DEV vpc web"

  ingress {
    description = "Allow port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description      = "Allow All Outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "vpc_web"
  }
}


#Allow HTTP,HTTPS


resource "aws_security_group" "vpc_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"

  ingress {
    description = "vpv_ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

```
- Reference the security groups in `tf_resouces.tf` file as a list item
```t
# List Item
vpc_security_group_ids = [
    aws_security_group.vpc_ssh.id,
    aws_security_group.vpc_web.id
  ]  
```

## s4: data_sources.tf - Define Get Latest AMI ID for Amazon Linux2 OS
- [Data Source: aws_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami)
```t
# Get latest AMI ID for Amazon Linux2 OS
# Get Latest AWS AMI ID for Amazon2 Linux
data "aws_ami" "amzn_linux2" {
  #   executable_users = ["self"]
  most_recent = true
  #   name_regex  = "^myami-\\d{3}"
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Availability zone data sources
data "aws_availability_zones" "syler_az" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

```
- Reference the datasource in `tf_resouces.tf` file
```t
# Reference Datasource to get the latest AMI ID
ami = data.aws_ami.amzlinux2.id 
```

## S5: tf_resouces.tf - Define EC2 Instance Resource
- [Resource: aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
```t
# EC2 Instance
resource "aws_instance" "syler-ec2" {
  ami = data.aws_ami.amzn_linux2.id
  # instance_type = var.instance_type #Normal
  # instance_type = var.instance_type_list[1] # instance type list 
  instance_type     = var.instance_type_map["dev"] # instance type map
  availability_zone = each.key                     # you can use each.value because for list items each.key = each.value

  user_data = file("${path.module}/app1-install.sh")
  # key_name  = var.instance_keypair
  vpc_security_group_ids = [
    aws_security_group.vpc_ssh.id,
    aws_security_group.vpc_web.id
  ]
  for_each = toset(data.aws_availability_zones.syler_az.names)
  tags = {
    "Name" = "For-each-EC2-TF-SAMPLE-DEMO-PROJECT-V4-${each.value}" # for map (each.key != each.value) , for string (each.key = each.value)
  }
}
```


## S6: output.tf - Define Output Values 
- [Output Values](https://www.terraform.io/docs/language/values/outputs.html)
```t
# Terraform Output Values


# EC2 Instance Public IP with TOSET
output "instance_publicip" {
  description = "EC2 Instance Public IP"
  #value = aws_instance.syler-ec2.*.public_ip   # Legacy Splat
  #value = aws_instance.syler-ec2[*].public_ip  # Latest Splat
  value = toset([for instance in aws_instance.syler-ec2 : instance.public_ip])
}

# EC2 Instance Public DNS with TOSET
output "instance_publicdns" {
  description = "EC2 Instance Public DNS"
  #value = aws_instance.syler-ec2[*].public_dns  # Legacy Splat
  #value = aws_instance.syler-ec2[*].public_dns  # Latest Splat
  value = toset([for instance in aws_instance.syler-ec2 : instance.public_dns])
}

# EC2 Instance Public DNS with TOMAP
output "instance_publicdns2" {
  value = tomap({ for az, instance in aws_instance.syler-ec2 : az => instance.public_dns })
}

```



## S7: Access Application
```t
# Access index.html
http://<PUBLIC-IP>/index.html
http://<PUBLIC-IP>/app1/index.html

# Access metadata.html
http://<PUBLIC-IP>/app1/metadata.html
```

## S8: Clean-Up To Save Cost
```t
# Terraform Destroy
terraform plan -destroy  # You can view destroy plan using this command
terraform destroy

# Clean-Up Files
rm -rf .terraform*
rm -rf terraform.tfstate*
```
  