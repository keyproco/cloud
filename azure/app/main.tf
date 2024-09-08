resource "azurerm_service_plan" "sp" {
  name                = "web-appserviceplan"
  location            = var.location
  resource_group_name = var.resource_group_name

  os_type = "Windows"
  sku_name = "S1"

  tags = {
    Owner = "Keyproco"
  }
}


resource "azurerm_windows_web_app" "w_webapp" {
  name                = "windows-app-${var.resource_group_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id = azurerm_service_plan.sp.id

  site_config {

  }

  depends_on = [
    azurerm_app_service_source_control_token.github
  ]
}


resource "azurerm_app_service_source_control" "webapp_source_control" {
  app_id               = azurerm_windows_web_app.w_webapp.id
  repo_url             = "https://github.com/keyproco/ausemartweb.git"
  branch               = "main"

   depends_on = [
    azurerm_app_service_source_control_token.github
  ]

}


resource "azurerm_app_service_source_control_token" "github" {
  type  = "GitHub"
  token = var.github_token
}