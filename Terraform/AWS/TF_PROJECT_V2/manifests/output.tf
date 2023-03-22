#public ip

output "instance_public_ip" {
  description = "EC2 Instance Public"
  value       = aws_instance.syler-ec2.public_ip
}

#public dns

output "instance_public_dns" {
  description = "EC2 Instance Public"
  value       = aws_instance.syler-ec2.public_dns
}

