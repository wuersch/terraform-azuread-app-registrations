# Azure blob storage backend for production tenant
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstatemwuprod"
    container_name       = "tfstate"
    key                  = "prod/terraform.tfstate"
  }
}
