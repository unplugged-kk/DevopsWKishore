module "public_bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"


  name        = "public_bastion_sg"
  description = "Security group with SSH and egress to all allowed"
  vpc_id      = module.vpc.vpc_id

  #Ingress Rules & CIDR
  ingress_rules       = ["ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  #Egress Rules  & CIDR
  egress_rules = ["all-all"]
  tags         = local.common_tags

}

