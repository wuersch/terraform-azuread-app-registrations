terraform {
  required_version = ">= 1.0"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47"
    }
  }
}

provider "azuread" {
  # Authentication via Azure CLI: az login
  # Or set environment variables:
  # - ARM_CLIENT_ID
  # - ARM_CLIENT_SECRET
  # - ARM_TENANT_ID
}
