variable "display_name" {
  description = "Display name for the backend app registration"
  type        = string
}

variable "sign_in_audience" {
  description = "Sign-in audience for the application"
  type        = string
  default     = "AzureADMyOrg"
  validation {
    condition     = contains(["AzureADMyOrg", "AzureADMultipleOrgs", "AzureADandPersonalMicrosoftAccount"], var.sign_in_audience)
    error_message = "sign_in_audience must be one of: AzureADMyOrg, AzureADMultipleOrgs, AzureADandPersonalMicrosoftAccount"
  }
}

variable "app_roles" {
  description = "Map of app roles to create. Key is the role value, object contains display_name, description, and optionally allowed_member_types (defaults to [\"User\"], use [\"Application\"] or [\"User\", \"Application\"] for client credential flow)."
  type = map(object({
    display_name         = string
    description          = string
    allowed_member_types = optional(list(string), ["User"])
  }))
  default = {
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
  }
  validation {
    condition = alltrue([
      for role in values(var.app_roles) : alltrue([
        for member_type in role.allowed_member_types : contains(["User", "Application"], member_type)
      ])
    ])
    error_message = "allowed_member_types must only contain 'User' and/or 'Application'"
  }
}

variable "create_role_groups" {
  description = "Create security groups for each app role (for testing)"
  type        = bool
  default     = false
}

variable "role_group_assignments" {
  description = "Map of role names to existing group object IDs for role assignments. Keys must match app_roles keys."
  type        = map(string)
  default     = {}
}

variable "enable_claims_mapping" {
  description = "Enable claims mapping policy for sAMAccountName (requires Azure AD Premium)"
  type        = bool
  default     = false
}

variable "owners" {
  description = "List of object IDs of users or service principals to set as owners of the app registration. Minimum 2 required (primary + deputy)."
  type        = list(string)
  validation {
    condition     = length(var.owners) >= 2
    error_message = "At least 2 owners must be provided (primary + deputy)"
  }
}

