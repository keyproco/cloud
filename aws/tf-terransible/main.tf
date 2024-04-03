#----------------------
# Network
#--------------------

resource "aws_vpc" "terransible_vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "terransible_vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.terransible_vpc.id

  tags = {
    Name = "terransible_gw"
  }
}