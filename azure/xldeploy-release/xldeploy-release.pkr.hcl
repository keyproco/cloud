

source "azure-arm" "xldeploy" {
  azure_tags = {
    dept = "Engineering"
    task = "Image deployment"
  }
  
  subscription_id = "{{env `AZURE_SUBSCRIPTION_ID`}}"
  client_id       = "{{env `AZURE_CLIENT_ID`}}"
  client_secret   = "{{env `AZURE_CLIENT_SECRET`}}"
  tenant_id       = "{{env `AZURE_TENANT_ID`}}"

  image_offer                       = "0001-com-ubuntu-server-jammy"
  image_publisher                   = "canonical"
  image_sku                         = "22_04-lts"
  location                          = "West Europe"
  managed_image_name                = "xl-deploy-release"
  managed_image_resource_group_name = "labspace"
  os_type                           = "Linux"
  vm_size                           = "Standard_DS2_v2"
}

build {
  sources = ["source.azure-arm.xldeploy"]

  provisioner "file" {
  source      = "install.sh"
  destination = "/tmp/install.sh"
}

provisioner "shell" {
  execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
  inline = [
    "apt-get update",
    "apt-get upgrade -y",
    "chmod +x /tmp/install.sh",
    "sudo /tmp/install.sh"
  ]
  inline_shebang  = "/bin/sh -x"
}

}