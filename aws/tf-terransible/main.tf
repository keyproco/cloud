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