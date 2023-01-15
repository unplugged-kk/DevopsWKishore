# AWS EC2 Instance Terraform Outputs
# Public EC2 Instances - Bastion Host

## ec2_bastion_public_instance_ids
output "ec2_bastion_public_instance_ids" {
  description = "List of IDs of instances"
  value       = module.ec2_public.id
}

## ec2_bastion_public_ip
output "ec2_bastion_public_ip" {
  description = "List of public IP addresses assigned to the instances"
  value       = module.ec2_public.public_ip
}

# Private EC2 Instances
# ec2_private_instance_ids
output "ec2_private_instance_ids" {
  description = "List of IDs of instances"
  value       = [module.ec2_private["app_vm1"].id, module.ec2_private["app_vm2"].id]
}
## ec2_private_ip
output "ec2_private_ip" {
  description = "List of private IP addresses assigned to the instances"
  value       = [module.ec2_private["app_vm1"].private_ip, module.ec2_private["app_vm2"].private_ip]
}

## ec2_private_whole_module_output
output "ec2_private_module" {
  description = "The full output of the `ec2_private` module"
  value       = module.ec2_private
}
