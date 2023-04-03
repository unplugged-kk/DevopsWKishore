
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
