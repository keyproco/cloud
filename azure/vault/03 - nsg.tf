resource "azurerm_network_security_group" "_" {
  name                = "allow-admin-nsg"
  location            = azurerm_resource_group._.location
  resource_group_name = azurerm_resource_group._.name

  tags = {
    environment = "testing"
  }
}

resource "azurerm_network_security_rule" "allow_icmp" {
  network_security_group_name = azurerm_network_security_group._.name
  resource_group_name         = azurerm_resource_group._.name
  name                        = "allow-icmp"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "allow_http_https" {
  network_security_group_name = azurerm_network_security_group._.name
  resource_group_name         = azurerm_resource_group._.name
  name                        = "allow-http-https"
  priority                    = 1011
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["80", "443", "8200", "8201"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "allow_ssh" {
  network_security_group_name = azurerm_network_security_group._.name
  resource_group_name         = azurerm_resource_group._.name
  name                        = "allow-ssh"
  priority                    = 1010
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_interface_security_group_association" "association" {
  for_each = azurerm_network_interface.vm

  network_interface_id      = each.value.id
  network_security_group_id = azurerm_network_security_group._.id
}

resource "azurerm_subnet_network_security_group_association" "__" {
  subnet_id                 = azurerm_subnet._["alpha"].id
  network_security_group_id = azurerm_network_security_group._.id
}