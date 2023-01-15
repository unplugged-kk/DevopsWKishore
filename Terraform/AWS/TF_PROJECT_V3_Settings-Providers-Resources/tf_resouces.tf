#Resource Block

resource "aws_instance" "syler-ec2" {
  ami = data.aws_ami.amzn_linux2.id
  # instance_type = var.instance_type #Normal
  # instance_type = var.instance_type_list[1] # instance type list 
  instance_type = var.instance_type_map["prod"] # instance type map

  user_data = file("${path.module}/app1-install.sh")
  key_name  = var.instance_keypair
  vpc_security_group_ids = [
    aws_security_group.vpc_ssh.id,
    aws_security_group.vpc_web.id
  ]
  count = 2 #meta arguments
  tags = {
    "Name" = "EC2-TF-SAMPLE-DEMO-PROJECT-V3-${count.index}"
  }
}
