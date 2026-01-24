# Backend configurations
output "backends" {
  description = "All backend configurations"
  value = {
    for key, backend in module.backend : key => {
      application_id       = backend.application_id
      identifier_uri       = backend.identifier_uri
      service_principal_id = backend.service_principal_id
      spring_boot_config   = backend.spring_boot_config
      role_group_ids       = backend.role_group_ids
    }
  }
}

# SPA configurations
output "spas" {
  description = "All SPA configurations"
  value = {
    for key, spa in module.spa : key => {
      application_id       = spa.application_id
      service_principal_id = spa.service_principal_id
      msal_config          = spa.msal_config
      backend              = var.spas[key].backend
    }
  }
}
