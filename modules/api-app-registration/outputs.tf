output "application_id" {
  description = "Application (client) ID"
  value       = azuread_application.api.client_id
}

output "object_id" {
  description = "Application object ID"
  value       = azuread_application.api.object_id
}

output "id" {
  description = "Application resource ID (for use with pre_authorized)"
  value       = azuread_application.api.id
}

output "service_principal_id" {
  description = "Service principal object ID"
  value       = azuread_service_principal.api.object_id
}

output "identifier_uri" {
  description = "Application identifier URI (api://...)"
  value       = "api://${azuread_application.api.client_id}"
}

output "oauth2_scope_ids" {
  description = "Map of OAuth2 scope names to their IDs"
  value = {
    user_access = random_uuid.user_access_scope.result
  }
}

output "app_role_ids" {
  description = "Map of app role names to their IDs"
  value = {
    user   = random_uuid.role_user.result
    viewer = random_uuid.role_viewer.result
    admin  = random_uuid.role_admin.result
  }
}

output "client_secret" {
  description = "Client secret value (only if create_client_secret=true)"
  value       = var.create_client_secret ? azuread_application_password.api[0].value : null
  sensitive   = true
}

output "role_group_ids" {
  description = "Map of role names to created group object IDs (only if create_role_groups=true)"
  value = var.create_role_groups ? {
    user   = azuread_group.role_groups["user"].object_id
    viewer = azuread_group.role_groups["viewer"].object_id
    admin  = azuread_group.role_groups["admin"].object_id
  } : {}
}

output "spring_boot_config" {
  description = "Spring Boot Azure AD configuration object"
  value = {
    spring = {
      cloud = {
        azure = {
          active-directory = {
            enabled = true
            credential = {
              client-id = azuread_application.api.client_id
            }
            app-id-uri = "api://${azuread_application.api.client_id}"
          }
        }
      }
      security = {
        oauth2 = {
          resourceserver = {
            jwt = {
              issuer-uri = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/v2.0"
              jwk-set-uri = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/discovery/v2.0/keys"
            }
          }
        }
      }
    }
  }
}
