variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "aws_region" {
  default = "eu-west-3"
}

variable "dasboto_networks" {
  type = map(map(any))

  default = {
    "eu-west-3a" = {
      "sn-reserved-A" = {
        cidr_block = "10.16.0.0/20"
      },
      "sn-db-A" = {
        cidr_block = "10.16.16.0/20"
      },
      "sn-app-A" = {
        cidr_block = "10.16.32.0/20"
      },
      "sn-web-A" = {
        cidr_block = "10.16.48.0/20"
      },
    },

    "eu-west-3b" = {
      "sn-reserved-B" = {
        cidr_block = "10.16.64.0/20"
      },
      "sn-db-B" = {
        cidr_block = "10.16.80.0/20"
      },
      "sn-app-B" = {
        cidr_block = "10.16.96.0/20"
      },
      "sn-web-B" = {
        cidr_block = "10.16.112.0/20"
      },
    },

    "eu-west-3c" = {

      "sn-reserved-C" = {
        cidr_block = "10.16.128.0/20"
      },
      "sn-db-C" = {
        cidr_block = "10.16.144.0/20"
      },
      "sn-app-C" = {
        cidr_block = "10.16.160.0/20"
      },
      "sn-web-C" = {
        cidr_block = "10.16.176.0/20"
      },
    },
  }
}
