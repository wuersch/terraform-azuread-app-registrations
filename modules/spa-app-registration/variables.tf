variable "display_name" {
  description = "Display name for the SPA app registration"
  type        = string
}

variable "redirect_uris" {
  description = "List of redirect URIs for the SPA"
  type        = list(string)
  validation {
    condition     = length(var.redirect_uris) > 0
    error_message = "At least one redirect URI must be provided"
  }
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

variable "backend" {
  description = "Backend API module reference. Provides client_id, scope_id, and enables pre-authorization."
  type = object({
    application_id   = string
    id               = string
    oauth2_scope_ids = map(string)
  })
}

variable "owners" {
  description = "List of object IDs of users or service principals to set as owners of the app registration."
  type        = list(string)
  validation {
    condition     = length(var.owners) >= 1
    error_message = "At least 1 owner must be provided"
  }
}
