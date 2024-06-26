variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "sender_email" {}
variable "aws_region" {
  default = "eu-west-3"
}

variable "vpc_cidr" {
  type    = string
  default = "10.42.0.0/16"
}

variable "public_cidr" {
  type    = string
  default = "10.42.1.0/24"
}


variable "ami" {
  default = "ami-04b7bf9494d21c5bb"
}