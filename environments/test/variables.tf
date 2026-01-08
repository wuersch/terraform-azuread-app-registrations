variable "environment" {
  description = "Environment/stage name (e.g., dev, int, preprod)"
  type        = string
}

variable "app_name" {
  description = "Base name for the application"
  type        = string
}

variable "spa_redirect_uris" {
  description = "Redirect URIs for the SPA"
  type        = list(string)
}

variable "create_role_groups" {
  description = "Create security groups for app roles (for testing)"
  type        = bool
  default     = false
}

variable "role_group_assignments" {
  description = "Map of role names to existing group object IDs"
  type        = map(string)
  default     = {}
}

variable "enable_claims_mapping" {
  description = "Enable claims mapping policy (requires Azure AD Premium)"
  type        = bool
  default     = false
}
