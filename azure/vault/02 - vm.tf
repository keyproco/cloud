
# TODOS
# WIP failed to get raft challenge error [stuck]
# vms without public ip
# assign private ip for each vm
# attach lb to vault vms

module "ssh_keys" {
  source = "./ssh_keys"
}

resource "null_resource" "render_vault_installation" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "echo '${templatefile("${path.module}/templates/install_vault.tpl", {
      vault_version    = var.vault_version,
      node_id          = var.node_id,
      api_addr         = var.api_addr,
      cluster_addr     = var.cluster_addr,
      leader_api_addr  = var.leader_api_addr
    })}' > ./scripts/install_vault.sh"
  }
}


resource "azurerm_linux_virtual_machine" "vault" {

  for_each            = var.vault_nodes
  name                = each.value.vm_name
  resource_group_name = azurerm_resource_group._.name
  location            = azurerm_resource_group._.location
  size                = "Standard_B1s"
  admin_username      = each.value.admin_username
  network_interface_ids = [
    azurerm_network_interface.vm[each.key].id,
  ]

    custom_data = filebase64("${path.module}/scripts/install_vault.sh")

  admin_ssh_key {
    username   = each.value.admin_username
    public_key = file("${path.module}/ssh_keys/keys/public_key.pem")
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
  for_each            = var.vault_nodes
  name                = "${each.value.vm_name}-public-ip"
  location            = azurerm_resource_group._.location
  resource_group_name = azurerm_resource_group._.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "vm" {
  for_each            = var.vault_nodes
  name                = "${each.value.vm_name}-nic"
  location            = azurerm_resource_group._.location
  resource_group_name = azurerm_resource_group._.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet._["alpha"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip[each.key].id
  }
}