# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "azurerm" {
    resource_group_name  = "labspace"
    storage_account_name = "terraform2labspace"
    container_name       = "tfstate"
    key                  = "vault.terraform.tfstate"       
  }
}
