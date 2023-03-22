#Input Variable


#AWS region

variable "aws_region" {
  description = "Regions where aws resources to be created"
  type        = string
  default     = "us-east-1"
}


#AWS Instance type

variable "instance_type" {
  description = "Type of aws instance"
  type        = string
  default     = "t3.micro"
}

#AWS EC2 key pair

variable "instance_keypair" {

  description = "EC2 keypair which needs to be associated with ec2 vm"
  type        = string
  default     = "terraform-key"

}
