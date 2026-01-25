# Backend App Registrations
module "backend" {
  for_each = var.backends
  source   = "../../modules/backend-app-registration"

  display_name           = "${each.value.app_name}-Backend-${upper(var.environment)}"
  app_roles              = each.value.app_roles
  create_role_groups     = each.value.create_role_groups
  role_group_assignments = each.value.role_group_assignments
  enable_claims_mapping  = each.value.enable_claims_mapping
  owners                 = each.value.owners
}

# Backend-to-backend role assignments (client credential flow)
locals {
  backend_role_assignments = flatten([
    for caller_key, caller_config in var.backends : [
      for target_key, target_config in caller_config.target_backends : [
        for role in target_config.roles : {
          key        = "${caller_key}_to_${target_key}_${role}"
          caller_key = caller_key
          target_key = target_key
          role       = role
        }
      ]
    ]
  ])
}

resource "azuread_app_role_assignment" "backend_to_backend" {
  for_each = { for assignment in local.backend_role_assignments : assignment.key => assignment }

  app_role_id         = module.backend[each.value.target_key].app_role_ids[each.value.role]
  principal_object_id = module.backend[each.value.caller_key].service_principal_id
  resource_object_id  = module.backend[each.value.target_key].service_principal_id
}

# SPA App Registrations
module "spa" {
  for_each = var.spas
  source   = "../../modules/spa-app-registration"

  display_name  = "${each.value.app_name}-Frontend-${upper(var.environment)}"
  redirect_uris = each.value.redirect_uris
  backend       = module.backend[each.value.backend]
  owners        = each.value.owners
}
