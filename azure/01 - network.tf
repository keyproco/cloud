
resource "azurerm_resource_group" "_" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "_" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group._.name
  location            = var.location
  address_space       = var.vnet_address_space
}


resource "azurerm_subnet" "_" {
  for_each            = var.subnet_ranges
  name                = each.key
  resource_group_name = azurerm_resource_group._.name
  virtual_network_name = azurerm_virtual_network._.name

  address_prefixes = [each.value]
}

variable "subnet_ranges" {
  type        = map(string)
  default     = {
    "alpha" = "10.42.1.0/27",
    "bravo" = "10.42.1.32/27",
    "charlie" = "10.42.1.64/27",
  }
}

