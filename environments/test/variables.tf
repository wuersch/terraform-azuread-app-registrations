variable "environment" {
  description = "Environment/stage name (e.g., dev, int, preprod)"
  type        = string
}

variable "backends" {
  description = "Map of backend APIs to create"
  type = map(object({
    display_name = string
    app_roles = optional(map(object({
      display_name = string
      description  = string
    })), {
      user = {
        display_name = "User"
        description  = "Standard user access"
      }
      viewer = {
        display_name = "Viewer"
        description  = "Read-only access"
      }
      admin = {
        display_name = "Admin"
        description  = "Administrative access"
      }
    })
    create_role_groups     = optional(bool, false)
    role_group_assignments = optional(map(string), {})
    enable_claims_mapping  = optional(bool, false)
    owners                 = list(string) # Required: minimum 2 owners (primary + deputy)
  }))
}

variable "spas" {
  description = "Map of SPAs to create. Each SPA references a backend by key."
  type = map(object({
    display_name  = string
    backend       = string # Key from backends map
    redirect_uris = list(string)
    owners        = list(string) # Required: minimum 2 owners (primary + deputy)
  }))
}

