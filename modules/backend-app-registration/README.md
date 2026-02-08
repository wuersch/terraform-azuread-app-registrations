# API App Registration Module

Creates an Entra ID App Registration for a backend API with OAuth2 scopes and app roles.

## Usage

```hcl
module "api" {
  source = "../../modules/api-app-registration"

  display_name           = "My API"
  create_role_groups     = true
  enable_claims_mapping  = false
  owners = ["00000000-0000-0000-0000-000000000000"]
}
```

### Custom App Roles

```hcl
module "api" {
  source = "../../modules/api-app-registration"

  display_name = "My API"
  app_roles = {
    reader = {
      display_name = "Reader"
      description  = "Read-only access"
    }
    writer = {
      display_name = "Writer"
      description  = "Read-write access"
    }
    superuser = {
      display_name = "Superuser"
      description  = "Full access"
    }
  }
  owners = ["00000000-0000-0000-0000-000000000000"]
}
```

## Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `display_name` | string | required | Display name for the app registration |
| `sign_in_audience` | string | `"AzureADMyOrg"` | Sign-in audience |
| `app_roles` | map(object) | user/viewer/admin | Map of app roles to create |
| `create_role_groups` | bool | `false` | Create security groups for roles |
| `role_group_assignments` | map(string) | `{}` | Map role names to existing group IDs |
| `enable_claims_mapping` | bool | `false` | Enable sAMAccountName claim (requires Premium) |
| `owners` | list(string) | required | Object IDs of users/service principals |

## Outputs

| Name | Description |
|------|-------------|
| `application_id` | Application (client) ID |
| `object_id` | Application object ID |
| `id` | Application resource ID (for pre-authorization) |
| `service_principal_id` | Service principal object ID |
| `identifier_uri` | API identifier URI (`api://...`) |
| `oauth2_scope_ids` | Map of scope names to IDs |
| `app_role_ids` | Map of role names to IDs |
| `role_group_ids` | Created group IDs (if `create_role_groups=true`) |
| `spring_boot_config` | Spring Boot Azure AD configuration object |

## App Roles

By default, creates three roles (user, viewer, admin). Override with the `app_roles` variable to customize.

The map key becomes the role `value` claim in tokens.

## OAuth2 Scopes

| Scope | Value | Consent |
|-------|-------|---------|
| User Access | `user_access` | Admin only |

## Client Secrets

This module does not manage client secrets. Secrets should be created manually in the Azure Portal under "Certificates & secrets".

**Rationale:** Client secrets have a lifecycle that often differs from the infrastructure lifecycle. Consuming applications need to be updated when secrets are rotated, which requires coordination between teams. Managing secrets outside of Terraform allows teams to rotate secrets on their own schedule without requiring infrastructure changes.
