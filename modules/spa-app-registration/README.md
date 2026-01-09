# SPA App Registration Module

Creates an Entra ID App Registration for a Single Page Application using PKCE authentication.

## Usage

```hcl
module "spa" {
  source = "../../modules/spa-app-registration"

  display_name  = "My SPA"
  redirect_uris = ["http://localhost:3000"]
  backend       = module.api
}
```

## Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `display_name` | string | required | Display name for the app registration |
| `redirect_uris` | list(string) | required | SPA redirect URIs |
| `sign_in_audience` | string | `"AzureADMyOrg"` | Sign-in audience |
| `backend` | object | required | Backend API module reference (provides client_id, scope_id, pre-authorization) |
| `owners` | list(string) | `[]` | Object IDs of users/service principals to set as owners |

## Outputs

| Name | Description |
|------|-------------|
| `application_id` | Application (client) ID |
| `object_id` | Application object ID |
| `service_principal_id` | Service principal object ID |
| `msal_config` | MSAL.js configuration object |

## Security Configuration

- **Authentication**: Authorization Code flow with PKCE
- **Implicit flow**: Disabled (both access and ID tokens)
- **Client secret**: Not used (public client)
- **Pre-authorization**: Automatically configured for backend API access

## API Permissions

Automatically configured:

| API | Permission | Type |
|-----|------------|------|
| Microsoft Graph | `User.Read` | Delegated |
| Backend API | `user_access` | Delegated (pre-authorized) |

## MSAL.js Configuration

The `msal_config` output provides ready-to-use configuration:

```javascript
const msalConfig = {
  auth: {
    clientId: "...",
    authority: "https://login.microsoftonline.com/...",
    redirectUri: "http://localhost:3000"
  }
};

const apiScopes = ["api://.../user_access"];
```
