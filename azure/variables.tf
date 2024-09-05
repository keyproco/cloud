variable "resource_group_name" {
  default     = "labspace"
}

variable "location" {
  default     = "West Europe"
}

variable "vnet_name" {
  default     = "labspace-network"
}

variable "vnet_address_space" {
  default     = ["10.42.1.0/24"]
}


variable "subscription_id" {
  type        = string
}

variable "client_id" {
  type        = string
}

variable "client_secret" {
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  type        = string
}
