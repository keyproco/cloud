
#####################
# NETWORK 
#####################
resource "aws_vpc" "main" {

  cidr_block = "10.16.0.0/16"
  #   assign_generated_ipv6_cidr_block = true
  instance_tenancy = "default"

  tags = {
    Name = "dasboto"
  }

  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "sn_dasboto" {
  for_each = merge([
    for az_key, az_value in var.dasboto_networks : {
      for subnet_key, subnet_value in az_value :
      "${az_key}-${subnet_key}" => {
        vpc_id            = aws_vpc.main.id
        cidr_block        = subnet_value.cidr_block
        availability_zone = az_key
        tags = {
          Name = subnet_key
        }
      }
    }
  ]...)

  vpc_id = each.value.vpc_id

  cidr_block = each.value.cidr_block

  #   assign_ipv6_address_on_creation = true

  availability_zone = each.value.availability_zone

  tags = each.value.tags
}

#####################
# INTERNET GATEWAY 
#####################
resource "aws_internet_gateway" "dasboto" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${aws_vpc.main.tags.Name}-web-igw"
  }

}

resource "aws_route_table" "ig" {

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dasboto.id
  }


  tags = {
    Name = "dasboto-web-rt-igw"
  }
}

resource "aws_route_table_association" "web_rt_assoc" {

  for_each = {
    for key, value in aws_subnet.sn_dasboto : key => value if split("-", value.tags.Name)[1] == "web"
  }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.ig.id

}

#####################
# NAT RESOURCES CONFIG
#####################
resource "aws_eip" "dasboto_ng" {
  for_each = {
    for key, value in aws_subnet.sn_dasboto : key => value if split("-", value.tags.Name)[1] == "web"
  }

  domain = "vpc"
  tags = {
    SubnetName       = each.value.tags.Name
    SubnetId         = each.value.id
    AvailabilityZone = each.value.availability_zone
  }
}

resource "aws_nat_gateway" "dasboto_ng" {
  for_each = aws_eip.dasboto_ng

  allocation_id = each.value.id
  subnet_id     = each.value.tags.SubnetId

  tags = {
    Name = "gw-nat-dasboto-${each.value.tags.AvailabilityZone}"
  }

  depends_on = [aws_internet_gateway.dasboto, aws_subnet.sn_dasboto]
}

########################
# NAT ROUTING
#####################
resource "aws_route_table" "dasboto" {
  for_each = aws_nat_gateway.dasboto_ng

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }

  tags = {
    Name = "rt-${each.value.tags["Name"]}"
  }

  depends_on = [aws_subnet.sn_dasboto]
}


resource "aws_route_table_association" "a_except_web_rt_assoc" {

  for_each = {
    for key, value in aws_subnet.sn_dasboto :
    key => value if value.availability_zone == "eu-west-3a" && split("-", key)[4] != "web"
  }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.dasboto["eu-west-3a-sn-web-A"].id
}

resource "aws_route_table_association" "b_except_web_rt_assoc" {

  for_each = {
    for key, value in aws_subnet.sn_dasboto :
    key => value if value.availability_zone == "eu-west-3b" && split("-", key)[4] != "web"
  }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.dasboto["eu-west-3b-sn-web-B"].id
}

resource "aws_route_table_association" "c_except_web_rt_assoc" {

  for_each = {
    for key, value in aws_subnet.sn_dasboto :
    key => value if value.availability_zone == "eu-west-3c" && split("-", key)[4] != "web"
  }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.dasboto["eu-west-3c-sn-web-C"].id
}


