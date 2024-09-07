
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
  for_each             = var.subnet_ranges
  name                 = each.key
  resource_group_name  = azurerm_resource_group._.name
  virtual_network_name = azurerm_virtual_network._.name

  address_prefixes = [each.value]
}

variable "subnet_ranges" {
  type = map(string)
  default = {
    "alpha"   = "10.42.1.0/27",
    "bravo"   = "10.42.1.32/27",
    "charlie" = "10.42.1.64/27",
  }
}

resource "azurerm_nat_gateway" "_" {
  name                = "labspace-gateway"
  location            = azurerm_resource_group._.location
  resource_group_name = azurerm_resource_group._.name
  tags = {
    environment = "testing"
  }
}

resource "azurerm_nat_gateway_public_ip_association" "_" {
  nat_gateway_id       = azurerm_nat_gateway._.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_public_ip" "nat" {
  name                = "spacelab-nat-ip"
  location            = azurerm_resource_group._.location
  resource_group_name = azurerm_resource_group._.name
  allocation_method   = "Static"

  tags = {
    environment = "testing"
  }
}

resource "azurerm_subnet_nat_gateway_association" "_" {
  for_each       = var.subnet_ranges
  subnet_id      = azurerm_subnet._[each.key].id
  nat_gateway_id = azurerm_nat_gateway._.id
}