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
