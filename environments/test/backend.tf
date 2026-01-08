# Local backend for personal tenant testing
# Switch to azurerm backend when ready for shared state
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# To switch to Azure blob storage, replace with:
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg-terraform-state"
#     storage_account_name = "stterraformstate"
#     container_name       = "tfstate"
#     key                  = "test/terraform.tfstate"
#   }
# }
