

resource "azurerm_public_ip" "lb_public_ip" {
  name                = "lb-public-ip"
  location            = azurerm_resource_group._.location
  resource_group_name = azurerm_resource_group._.name

  allocation_method = "Static"
  sku               = "Standard"
}


resource "azurerm_lb" "labspace" {
  name                = "TestLoadBalancer"
  location            = azurerm_resource_group._.location
  resource_group_name = azurerm_resource_group._.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }


}

resource "azurerm_network_interface_backend_address_pool_association" "nic_to_lb_pool" {
  network_interface_id    = azurerm_network_interface.vm.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.labspace.id
  ip_configuration_name   = "internal"
}

resource "azurerm_lb_rule" "labspace" {
  loadbalancer_id                = azurerm_lb.labspace.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.labspace.id]
}

resource "azurerm_lb_probe" "labspace" {
  loadbalancer_id = azurerm_lb.labspace.id
  name            = "http"
  port            = 80
}

resource "azurerm_lb_backend_address_pool" "labspace" {
  loadbalancer_id = azurerm_lb.labspace.id
  name            = "BackEndAddressPool"
}

output "load_balancer_public_ip" {
  value = azurerm_public_ip.lb_public_ip.ip_address
}