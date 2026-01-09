# API App Registration
module "api" {
  source = "../../modules/api-app-registration"

  display_name           = "${var.app_name} API (${upper(var.environment)})"
  role_group_assignments = var.role_group_assignments
  enable_claims_mapping  = var.enable_claims_mapping
}

# SPA App Registration
module "spa" {
  source = "../../modules/spa-app-registration"

  display_name  = "${var.app_name} SPA (${upper(var.environment)})"
  redirect_uris = var.spa_redirect_uris
  api_client_id = module.api.application_id
  api_scope_id  = module.api.oauth2_scope_ids["user_access"]
}

# Pre-authorize SPA to access API without additional consent
resource "azuread_application_pre_authorized" "spa_to_api" {
  application_id       = module.api.id
  authorized_client_id = module.spa.application_id
  permission_ids       = [module.api.oauth2_scope_ids["user_access"]]
}
