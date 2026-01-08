variable "display_name" {
  description = "Display name for the API app registration"
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

variable "create_client_secret" {
  description = "Create a client secret for service-to-service authentication"
  type        = bool
  default     = false
}

variable "client_secret_expiry_days" {
  description = "Number of days until the client secret expires"
  type        = number
  default     = 365
}

variable "create_role_groups" {
  description = "Create security groups for each app role (for testing)"
  type        = bool
  default     = false
}

variable "role_group_assignments" {
  description = "Map of role names to existing group object IDs for role assignments"
  type        = map(string)
  default     = {}
  validation {
    condition     = alltrue([for k, v in var.role_group_assignments : contains(["user", "viewer", "admin"], k)])
    error_message = "role_group_assignments keys must be one of: user, viewer, admin"
  }
}

variable "enable_claims_mapping" {
  description = "Enable claims mapping policy for sAMAccountName (requires Azure AD Premium)"
  type        = bool
  default     = false
}
