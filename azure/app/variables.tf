variable "resource_group_name" {
  default = "labspace"
}

variable "location" {
  default = "West Europe"
}

variable "vnet_name" {
  default = "app-network"
}

variable "subscription_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type      = string
  sensitive = true
}

variable "tenant_id" {
  type = string
}

variable "github_token" {
  type = string
}