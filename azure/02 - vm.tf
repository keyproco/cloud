resource "azurerm_linux_virtual_machine" "_" {
  name                = "nginx"
  resource_group_name = azurerm_resource_group._.name
  location            = azurerm_resource_group._.location
  size                = "Standard_B1ls"
  admin_username      = "leme"
  network_interface_ids = [
    azurerm_network_interface.vm.id,
  ]
  custom_data = filebase64("${path.module}/scripts/install_nginx.sh")
  admin_ssh_key {
    username   = "leme"
    public_key = file("${path.module}/ssh/public_key.pem")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_public_ip" "vm_public_ip" {
  name                = "vm-public-ip"
  location            = azurerm_resource_group._.location
  resource_group_name = azurerm_resource_group._.name

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_network_interface" "vm" {
  name                = "vm-nic"
  location            = azurerm_resource_group._.location
  resource_group_name = azurerm_resource_group._.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet._["alpha"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }

}