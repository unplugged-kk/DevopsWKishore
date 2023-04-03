resource "aws_eip" "ec2_bastion_eip" {
  vpc        = true
  instance   = module.ec2_bastion.id
  depends_on = [module.vpc, module.ec2_bastion]
  tags       = local.common_tags
}

## ec2_bastion_public_ip
output "ec2_bastion_eip" {
  description = "Elastic IP associated to the Bastion Host"
  value       = aws_eip.ec2_bastion_eip.public_ip
}
