
# resource "aws_security_group" "allow_ssh" {
#   name        = "allow_ssh"
#   description = "Allow SSH inbound traffic"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     description = "SSH from anywhere"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     description = "ICMP from anywhere"
#     from_port   = -1
#     to_port     = -1
#     protocol    = "icmp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "allow_ssh_anywhere"
#   }

# }

# data "aws_subnet" "sn_web_a" {
#   filter {
#     name   = "tag:Name"
#     values = ["sn-web-A"]
#   }
#   depends_on = [aws_subnet.sn_dasboto]
# }

resource "aws_key_pair" "ias_dasbotoapp_kp" {
  key_name   = "ias-dasbotoapp-kp"
  public_key = file("~/.ssh/id_rsa_2.pub")
}


# resource "aws_instance" "web" {

#   ami                         = "ami-04b7bf9494d21c5bb"
#   instance_type               = "t2.micro"
#   associate_public_ip_address = true

#   subnet_id = data.aws_subnet.sn_web_a.id

#   key_name = "ias-dasbotoapp-kp"

#   tags = {
#     Name = "bastion-dasbotoapp"
#   }
#   user_data              = <<-EOF
#               #!/bin/bash
#               echo "Hello from test.txt!" > /tmp/test.txt
#               EOF
#   vpc_security_group_ids = [aws_security_group.allow_ssh.id]

# }