# API Outputs
output "api_application_id" {
  description = "API application (client) ID"
  value       = module.api.application_id
}

output "api_identifier_uri" {
  description = "API identifier URI"
  value       = module.api.identifier_uri
}

output "api_service_principal_id" {
  description = "API service principal object ID"
  value       = module.api.service_principal_id
}

# SPA Outputs
output "spa_application_id" {
  description = "SPA application (client) ID"
  value       = module.spa.application_id
}

output "spa_service_principal_id" {
  description = "SPA service principal object ID"
  value       = module.spa.service_principal_id
}

# Configuration Outputs
output "msal_config" {
  description = "MSAL.js configuration for frontend"
  value       = module.spa.msal_config
}

output "spring_boot_config" {
  description = "Spring Boot Azure AD configuration"
  value       = module.api.spring_boot_config
}

# Group Outputs (if created)
output "role_group_ids" {
  description = "Created role group IDs (if create_role_groups=true)"
  value       = module.api.role_group_ids
}
