module "private_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"


  name        = "private_sg"
  description = "Security group with Http open for the whole CIDR"
  vpc_id      = module.vpc.vpc_id

  #Ingress Rules & CIDR
  ingress_rules       = ["ssh-tcp", "http-80-tcp", "http-8080-tcp"]
  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  egress_rules        = ["all-all"]
  tags                = local.common_tags

}
