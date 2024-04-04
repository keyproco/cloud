#----------
# utils
#-------------

resource "random_id" "random" {
  byte_length = 2
}

#----------------------
# Network
#--------------------

resource "aws_vpc" "terransible_vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "terransible-vpc-${random_id.random.dec}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.terransible_vpc.id

  tags = {
    Name = "terransible-gw-${random_id.random.dec}"
  }
}

resource "aws_route_table" "terransible_rt" {
  vpc_id = aws_vpc.terransible_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Internet Gatway Route Table"
  }
}

resource "aws_default_route_table" "private_rt" {
  default_route_table_id = aws_vpc.terransible_vpc.default_route_table_id
  tags = {
    Name = "Terransible Private Route Table"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "terransible_public_subnet" {
  vpc_id                  = aws_vpc.terransible_vpc.id
  cidr_block              = var.public_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "Terransible Public Subnet"
  }
}

resource "aws_route_table_association" "terransible_public_subnet_association" {
  subnet_id      = aws_subnet.terransible_public_subnet.id
  route_table_id = aws_route_table.terransible_rt.id
}


resource "aws_security_group" "allow_ssh" {
  name        = "Allow ICMP and SSH"
  description = "Allow SSH and ICMP inbound traffic"
  vpc_id      = aws_vpc.terransible_vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTP 8080 from anywhere"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "ICMP from anywhere"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_icmp_ssh_anywhere"
  }

}



#-------------------
# Ec2 Instance
#------------------

# 
resource "aws_key_pair" "terransible_kp" {
  key_name   = "terransible-kp"
  public_key = file("~/.ssh/id_rsa_2.pub")
}

resource "aws_instance" "web" {

  ami                         = var.ami
  instance_type = "t2.medium"
  associate_public_ip_address = true

  subnet_id = aws_subnet.terransible_public_subnet.id

  key_name = "terransible-kp"

  tags = {
    Name = "Terransible Instance"
  }
  user_data              = <<-EOF
              #!/bin/bash
              echo "Hello from test.txt!" > /tmp/test.txt
              EOF
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

}
