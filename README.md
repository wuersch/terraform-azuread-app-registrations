# Terraform Entra ID App Registrations

Terraform modules for managing Azure Entra ID (Azure AD) App Registrations for SPA + Backend API architectures.

## Prerequisites

- Terraform >= 1.0
- Azure CLI (`az login` for authentication)
- Permissions to create App Registrations in your Entra ID tenant

## Structure

```
├── modules/
│   ├── api-app-registration/    # Backend API module
│   └── spa-app-registration/    # SPA frontend module
├── environments/
│   ├── test/                    # Test tenant (DEV, INT, PREPROD, PREPROD02)
│   └── prod/                    # Production tenant (separate state)
```

## Tenants and Environments

| Directory | Tenant | Stages | State |
|-----------|--------|--------|-------|
| `environments/test/` | Test tenant | DEV, INT, PREPROD, PREPROD02 | Local or Azure blob |
| `environments/prod/` | Production tenant | PROD | Azure blob (separate) |

Stages within the test tenant are distinguished by naming convention (e.g., "MyApp API (DEV)").

## Quick Start

```bash
# Authenticate to Azure
az login

# Deploy to test tenant
cd environments/test
terraform init
terraform plan
terraform apply
```

## Configuration

Edit `terraform.tfvars` to configure your applications:

```hcl
environment = "dev"

backends = {
  myapp = {
    display_name       = "MyApp API"
    create_role_groups = true
    # owners = ["00000000-0000-0000-0000-000000000000"]
  }
}

spas = {
  myapp-web = {
    display_name  = "MyApp Web"
    backend       = "myapp"  # References key from backends map
    redirect_uris = ["https://myapp.example.com", "http://localhost:3000"]
  }
}
```

### Multiple SPAs per Backend

You can have multiple SPAs sharing the same backend API:

```hcl
backends = {
  portal = {
    display_name       = "Portal API"
    create_role_groups = true
  }
}

spas = {
  portal-web = {
    display_name  = "Portal Web"
    backend       = "portal"
    redirect_uris = ["https://portal.example.com"]
  }
  portal-admin = {
    display_name  = "Portal Admin"
    backend       = "portal"
    redirect_uris = ["https://admin.portal.example.com"]
  }
}
```

### Custom App Roles

Override the default roles (user, viewer, admin):

```hcl
backends = {
  billing = {
    display_name = "Billing API"
    app_roles = {
      reader = {
        display_name = "Reader"
        description  = "View invoices"
      }
      admin = {
        display_name = "Admin"
        description  = "Manage billing"
      }
    }
    # Assign existing Azure AD groups to roles
    role_group_assignments = {
      reader = "11111111-1111-1111-1111-111111111111"
      admin  = "22222222-2222-2222-2222-222222222222"
    }
  }
}
```

## Outputs

### MSAL.js Configuration (Frontend)

```bash
terraform output -json spas
```

```json
{
  "myapp-web": {
    "msal_config": {
      "auth": {
        "clientId": "xxx",
        "authority": "https://login.microsoftonline.com/xxx",
        "redirectUri": "http://localhost:3000"
      },
      "api": {
        "scopes": ["api://xxx/user_access"]
      }
    }
  }
}
```

### Spring Boot Configuration (Backend)

```bash
terraform output -json backends
```

## Security Features

- **PKCE**: Authorization Code flow with PKCE (no client secrets for SPA)
- **No implicit flow**: Explicitly disabled
- **Admin consent**: API scope requires admin consent
- **App roles**: Configurable roles with group assignments
- **Pre-authorization**: SPAs are pre-authorized to access their backend API

## Optional Features

| Feature | Variable | Default | Requirement |
|---------|----------|---------|-------------|
| Create test groups | `create_role_groups` | false | - |
| Custom app roles | `app_roles` | user/viewer/admin | - |
| Set owners | `owners` | [] (creator) | - |
| Claims mapping | `enable_claims_mapping` | false | Azure AD Premium |

## Client Secrets

Client secrets are not managed by Terraform. Create them manually in the Azure Portal under "Certificates & secrets". See the [API module README](modules/api-app-registration/README.md#client-secrets) for rationale.

## Cost

All default features are **free**. Only `enable_claims_mapping` requires Azure AD Premium.
