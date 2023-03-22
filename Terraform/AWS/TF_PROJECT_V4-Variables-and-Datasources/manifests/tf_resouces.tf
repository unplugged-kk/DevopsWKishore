#Resource Block

resource "aws_instance" "syler-ec2" {
  ami = data.aws_ami.amzn_linux2.id
  # instance_type = var.instance_type #Normal
  # instance_type = var.instance_type_list[1] # instance type list 
  instance_type     = var.instance_type_map["dev"] # instance type map
  availability_zone = each.key                     # you can use each.value because for list items each.key = each.value

  user_data = file("${path.module}/app1-install.sh")
  # key_name  = var.instance_keypair
  vpc_security_group_ids = [
    aws_security_group.vpc_ssh.id,
    aws_security_group.vpc_web.id
  ]
  for_each = toset(data.aws_availability_zones.syler_az.names)
  tags = {
    "Name" = "For-each-EC2-TF-SAMPLE-DEMO-PROJECT-V4-${each.value}" # for map (each.key != each.value) , for string (each.key = each.value)
  }
}
