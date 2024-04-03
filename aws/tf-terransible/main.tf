#----------------------
# Network
#--------------------

resource "aws_vpc" "terransible_vpc" {
  cidr_block = "10.42.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "terransible_vpc"
  }
}