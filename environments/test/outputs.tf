# Backend API configurations
output "backends" {
  description = "All backend API configurations"
  value = {
    for key, api in module.api : key => {
      application_id       = api.application_id
      identifier_uri       = api.identifier_uri
      service_principal_id = api.service_principal_id
      spring_boot_config   = api.spring_boot_config
      role_group_ids       = api.role_group_ids
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
