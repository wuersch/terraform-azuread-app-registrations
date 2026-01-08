# API App Registration Module

Creates an Entra ID App Registration for a backend API with OAuth2 scopes and app roles.

## Usage

```hcl
module "api" {
  source = "../../modules/api-app-registration"

  display_name           = "My API"
  create_role_groups     = true
  enable_claims_mapping  = false
}
```

## Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `display_name` | string | required | Display name for the app registration |
| `sign_in_audience` | string | `"AzureADMyOrg"` | Sign-in audience |
| `create_client_secret` | bool | `false` | Create a client secret |
| `client_secret_expiry_days` | number | `365` | Secret expiry in days |
| `create_role_groups` | bool | `false` | Create security groups for roles |
| `role_group_assignments` | map(string) | `{}` | Map role names to existing group IDs |
| `enable_claims_mapping` | bool | `false` | Enable sAMAccountName claim (requires Premium) |

## Outputs

| Name | Description |
|------|-------------|
| `application_id` | Application (client) ID |
| `object_id` | Application object ID |
| `service_principal_id` | Service principal object ID |
| `identifier_uri` | API identifier URI (`api://...`) |
| `oauth2_scope_ids` | Map of scope names to IDs |
| `app_role_ids` | Map of role names to IDs |
| `client_secret` | Client secret (sensitive, if created) |
| `role_group_ids` | Created group IDs (if `create_role_groups=true`) |
| `spring_boot_config` | Spring Boot Azure AD configuration object |

## App Roles

Creates three default roles:

| Role | Value | Description |
|------|-------|-------------|
| User | `user` | Standard user access |
| Viewer | `viewer` | Read-only access |
| Admin | `admin` | Administrative access |

## OAuth2 Scopes

| Scope | Value | Consent |
|-------|-------|---------|
| User Access | `user_access` | Admin only |
