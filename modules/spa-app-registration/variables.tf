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

variable "api_client_id" {
  description = "Backend API application (client) ID"
  type        = string
}

variable "api_scope_id" {
  description = "Backend API user_access scope ID"
  type        = string
}
