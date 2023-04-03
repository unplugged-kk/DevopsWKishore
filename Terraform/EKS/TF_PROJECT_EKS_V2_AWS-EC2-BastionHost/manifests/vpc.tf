module "vpc" {

  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"
  name    = "${local.name}-${var.vpc_name}"
  cidr    = var.vpc_cidr_block

  # VPC Basic Details
  azs                   = var.vpc_availability_zones
  private_subnets       = var.vpc_private_subnets
  public_subnets        = var.vpc_public_subnets
  database_subnets      = var.vpc_database_subnets
  private_subnet_names  = var.vpc_private_subnet_names
  public_subnet_names   = var.vpc_public_subnet_names
  database_subnet_names = var.vpc_database_subnet_names

  manage_default_network_acl = true
  default_network_acl_tags   = { Name = "${local.name}-default" }

  manage_default_route_table = true
  default_route_table_tags   = { Name = "${local.name}-default" }

  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  # VPC DNS Parameters
  enable_dns_hostnames = true
  enable_dns_support   = true

  # NAT Gateways - Outbound Communication
  enable_nat_gateway = var.vpc_enable_nat_gateway
  single_nat_gateway = var.vpc_single_nat_gateway

  tags = local.common_tags

  # Additional Tags to Subnets
  public_subnet_tags = {
    Type = "Public Subnets"
  }
  private_subnet_tags = {
    Type = "Private Subnets"
  }
  database_subnet_tags = {
    Type = "Private Database Subnets"
  }

}
