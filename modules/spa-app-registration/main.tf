terraform {
  required_version = ">= 1.0"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47"
    }
  }
}

data "azuread_client_config" "current" {}

# Well-known Microsoft Graph API ID
locals {
  microsoft_graph_app_id = "00000003-0000-0000-c000-000000000000"
  # User.Read scope ID (delegated)
  user_read_scope_id = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
}

# SPA App Registration
resource "azuread_application" "spa" {
  display_name     = var.display_name
  sign_in_audience = var.sign_in_audience

  single_page_application {
    redirect_uris = var.redirect_uris
  }

  # Explicitly disable implicit flow
  web {
    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = false
    }
  }

  # Microsoft Graph User.Read permission
  required_resource_access {
    resource_app_id = local.microsoft_graph_app_id

    resource_access {
      id   = local.user_read_scope_id
      type = "Scope"
    }
  }

  # Backend API permission
  required_resource_access {
    resource_app_id = var.api_client_id

    resource_access {
      id   = var.api_scope_id
      type = "Scope"
    }
  }
}

# Service Principal (Enterprise App)
resource "azuread_service_principal" "spa" {
  client_id = azuread_application.spa.client_id
}
