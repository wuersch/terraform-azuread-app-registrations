# Azure blob storage backend for test tenant
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstatemwutest"
    container_name       = "tfstate"
    key                  = "test/terraform.tfstate"
  }
}
