variable "environment" {
  description = "Environment/stage name"
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

variable "role_group_assignments" {
  description = "Map of role names to existing group object IDs"
  type        = map(string)
  default     = {}
}

variable "enable_claims_mapping" {
  description = "Enable claims mapping policy for sAMAccountName"
  type        = bool
  default     = false
}
