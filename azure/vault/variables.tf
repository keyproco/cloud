variable "resource_group_name" {
  default = "labspace"
}

variable "location" {
  default = "West Europe"
}

variable "vnet_name" {
  default = "labspace-network"
}

variable "vnet_address_space" {
  default = ["10.42.1.0/24"]
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


variable "vault_nodes" {
  type = map(object({
    vm_name             = string
    size                = string
    admin_username      = string
  }))
  default = {
    "vault-node-1" = {
      vm_name            = "vault-node-1"
      size               = "Standard_B1ls"
      admin_username     = "key"
    }
    "vault-node-2" = {
      vm_name            = "vault-node-2"
      size               = "Standard_B1ls"
      admin_username     = "key"
    }
    "vault-node-3" = {
      vm_name            = "vault-node-3"
      size               = "Standard_B1ls"
      admin_username     = "key"
    }
  }
}

variable "vault_version" {
  default = "1.17.5"
}

variable "node_id" {
  default = "vault-node-1"
}

variable "api_addr" {
  default = "http://10.42.1.4:8200"
}

variable "cluster_addr" {
  default = "http://10.42.1.4:8201"
}

variable "leader_api_addr" {
  default = "http://10.42.1.4:8200"
}