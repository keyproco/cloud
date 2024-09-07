resource "azurerm_service_plan" "web" {
  name                = "web-appserviceplan"
  location            = var.location
  resource_group_name = var.resource_group_name

  os_type = "Linux"
  sku_name = "S1"

  tags = {
    Owner = "Keyproco"
  }
}


resource "azurerm_app_service" "app" {
  name                = "app-${var.resource_group_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_service_plan.web.id

  site_config {
    linux_fx_version = "DOCKER|ealen/echo-server:latest"
  }
}
