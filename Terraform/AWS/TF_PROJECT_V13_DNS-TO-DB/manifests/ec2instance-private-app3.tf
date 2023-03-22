module "ec2_private_app3" {
  source   = "terraform-aws-modules/ec2-instance/aws"
  version  = "3.6.0"
  for_each = local.multiple_instances

  name = "${var.environment}-${each.key}-app3"

  ami           = data.aws_ami.amzn_linux2.id
  instance_type = var.instance_type
  key_name      = var.instance_keypair
  #   monitoring             = true
  vpc_security_group_ids = [module.private_sg.security_group_id]
  subnet_id              = each.value.subnet_id
  #   instance_count = var.private_instance_count // outdated after 2.7 module
  tags       = local.common_tags
  user_data  = templatefile("app3-ums-install.tmpl", { rds_db_endpoint = module.rdsdb.db_instance_address })
  depends_on = [module.vpc]
}
