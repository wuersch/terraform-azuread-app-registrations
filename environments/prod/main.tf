# Backend API App Registrations
module "api" {
  for_each = var.backends
  source   = "../../modules/api-app-registration"

  display_name           = "${each.value.display_name} (${upper(var.environment)})"
  app_roles              = each.value.app_roles
  create_role_groups     = each.value.create_role_groups
  role_group_assignments = each.value.role_group_assignments
  enable_claims_mapping  = each.value.enable_claims_mapping
  owners                 = each.value.owners
}

# SPA App Registrations
module "spa" {
  for_each = var.spas
  source   = "../../modules/spa-app-registration"

  display_name  = "${each.value.display_name} (${upper(var.environment)})"
  redirect_uris = each.value.redirect_uris
  backend       = module.api[each.value.backend]
  owners        = each.value.owners
}
