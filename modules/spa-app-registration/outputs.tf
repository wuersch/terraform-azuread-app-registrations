output "application_id" {
  description = "Application (client) ID"
  value       = azuread_application.spa.client_id
}

output "object_id" {
  description = "Application object ID"
  value       = azuread_application.spa.object_id
}

output "service_principal_id" {
  description = "Service principal object ID"
  value       = azuread_service_principal.spa.object_id
}

output "msal_config" {
  description = "MSAL.js configuration object for frontend"
  value = {
    auth = {
      clientId    = azuread_application.spa.client_id
      authority   = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}"
      redirectUri = var.redirect_uris[0]
    }
    api = {
      scopes = ["api://${var.backend.application_id}/user_access"]
    }
  }
}
