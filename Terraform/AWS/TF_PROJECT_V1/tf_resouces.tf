#Resource Block

resource "aws_instance" "syler-ec2" {
  ami           = "ami-0b5eea76982371e91"
  instance_type = "t2.micro"
  user_data     = file("${path.module}/app1-install.sh")
  tags = {
    "Name" = "EC2-TF-SAMPLE-DEMO"
  }
}
