terraform {
  required_version = ">= 1.0"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

data "azuread_client_config" "current" {}

# Generate stable UUIDs for scopes and roles
resource "random_uuid" "user_access_scope" {}
resource "random_uuid" "role_user" {}
resource "random_uuid" "role_viewer" {}
resource "random_uuid" "role_admin" {}

# API App Registration
resource "azuread_application" "api" {
  display_name     = var.display_name
  sign_in_audience = var.sign_in_audience

  api {
    requested_access_token_version = var.enable_claims_mapping ? 2 : null

    oauth2_permission_scope {
      id                         = random_uuid.user_access_scope.result
      admin_consent_display_name = "Access ${var.display_name}"
      admin_consent_description  = "Allows the application to access ${var.display_name} on behalf of the signed-in user"
      value                      = "user_access"
      type                       = "Admin"
      enabled                    = true
    }
  }

  app_role {
    id                   = random_uuid.role_user.result
    display_name         = "User"
    description          = "Standard user access"
    value                = "user"
    allowed_member_types = ["User"]
    enabled              = true
  }

  app_role {
    id                   = random_uuid.role_viewer.result
    display_name         = "Viewer"
    description          = "Read-only access"
    value                = "viewer"
    allowed_member_types = ["User"]
    enabled              = true
  }

  app_role {
    id                   = random_uuid.role_admin.result
    display_name         = "Admin"
    description          = "Administrative access"
    value                = "admin"
    allowed_member_types = ["User"]
    enabled              = true
  }

  web {
    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = false
    }
  }

  lifecycle {
    ignore_changes = [identifier_uris]
  }
}


# Update identifier_uris to use actual application_id after creation
resource "azuread_application_identifier_uri" "api" {
  application_id = azuread_application.api.id
  identifier_uri = "api://${azuread_application.api.client_id}"
}

# Service Principal (Enterprise App)
resource "azuread_service_principal" "api" {
  client_id = azuread_application.api.client_id
  tags      = ["WindowsAzureActiveDirectoryIntegratedApp"]
}

# Optional: Client Secret
resource "azuread_application_password" "api" {
  count          = var.create_client_secret ? 1 : 0
  application_id = azuread_application.api.id
  display_name   = "Terraform managed secret"
  end_date_relative = "${var.client_secret_expiry_days * 24}h"
}

# Optional: Create security groups for role assignments
resource "azuread_group" "role_groups" {
  for_each         = var.create_role_groups ? toset(["user", "viewer", "admin"]) : toset([])
  display_name     = "${var.display_name}-${each.key}s"
  security_enabled = true
}

# Local map combining created groups and provided group assignments
locals {
  created_group_map = var.create_role_groups ? {
    user   = azuread_group.role_groups["user"].object_id
    viewer = azuread_group.role_groups["viewer"].object_id
    admin  = azuread_group.role_groups["admin"].object_id
  } : {}

  role_to_uuid = {
    user   = random_uuid.role_user.result
    viewer = random_uuid.role_viewer.result
    admin  = random_uuid.role_admin.result
  }

  # Merge created groups with provided group assignments (provided takes precedence)
  group_role_map = merge(local.created_group_map, var.role_group_assignments)
}

# App Role Assignments to Groups
resource "azuread_app_role_assignment" "group_roles" {
  for_each            = local.group_role_map
  app_role_id         = local.role_to_uuid[each.key]
  principal_object_id = each.value
  resource_object_id  = azuread_service_principal.api.object_id
}

# Optional: Claims Mapping Policy (requires Azure AD Premium)
resource "azuread_claims_mapping_policy" "api" {
  count        = var.enable_claims_mapping ? 1 : 0
  display_name = "${var.display_name} Claims Policy"
  definition = [jsonencode({
    ClaimsMappingPolicy = {
      Version              = 1
      IncludeBasicClaimSet = "true"
      ClaimsSchema = [
        {
          Source       = "user"
          ID           = "onpremisessamaccountname"
          JwtClaimType = "samaccountname"
        }
      ]
    }
  })]
}

resource "azuread_service_principal_claims_mapping_policy_assignment" "api" {
  count                    = var.enable_claims_mapping ? 1 : 0
  service_principal_id     = azuread_service_principal.api.id
  claims_mapping_policy_id = azuread_claims_mapping_policy.api[0].id
}
