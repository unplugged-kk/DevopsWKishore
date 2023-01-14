module "kishore-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"

  #VPC Basic Details

  name            = "vpc-dev"
  cidr            = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.11.0/24", "10.0.12.0/24"]

  # NAT -Gateway for Outbound access

  enable_nat_gateway = true
  single_nat_gateway = true

  #Database Subnets

  create_database_subnet_group       = true
  create_database_subnet_route_table = true
  # create_database_nat_gateway_route      = true
  # create_database_internet_gateway_route = true
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24"]

  #VPC DNS Parameters

  default_vpc_enable_dns_hostnames = true
  default_vpc_enable_dns_support   = true

  #Tags

  public_subnet_tags = {
    Type = "public-subnet"
  }

  private_subnet_tags = {
    Type = "private-subnet"
  }

  database_subnet_tags = {
    Type = "database-subnet"
  }

  tags = {
    Owner       = "Kishore"
    Environment = "dev"
  }

  vpc_tags = {
    Name = "vpc-dev"
  }

}
