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





