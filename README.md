# Terraform Entra ID App Registrations

Terraform modules for managing Azure Entra ID (Azure AD) App Registrations for SPA + Backend API architectures.

## Prerequisites

- Terraform >= 1.0
- Azure CLI (`az login` for authentication)
- Permissions to create App Registrations in your Entra ID tenant

## Structure

```
├── modules/
│   ├── backend-app-registration/   # Backend API module
│   └── spa-app-registration/       # SPA frontend module
├── environments/
│   ├── test/                       # Test tenant (DEV, INT, PREPROD, PREPROD02)
│   └── prod/                       # Production tenant (separate state)
```

## Tenants and Environments

| Directory | Tenant | Stages | State |
|-----------|--------|--------|-------|
| `environments/test/` | Test tenant | DEV, INT, PREPROD, PREPROD02 | Local or Azure blob |
| `environments/prod/` | Production tenant | PROD | Azure blob (separate) |

## Naming Convention

App names follow a strict naming convention (enforced by the module):

| Type | Pattern | Example |
|------|---------|---------|
| Backend | `{app_name}-Backend-{STAGE}` | `Portal-Backend-DEV` |
| Frontend (SPA) | `{app_name}-Frontend-{STAGE}` | `Portal-Frontend-DEV` |

You only provide the `app_name` (e.g., "Portal") - the suffix is added automatically.

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
    app_name           = "MyApp"
    create_role_groups = true
    owners = [
      "00000000-0000-0000-0000-000000000000",  # Primary owner object ID
      "11111111-1111-1111-1111-111111111111"   # Deputy owner object ID
    ]
  }
}

spas = {
  myapp-web = {
    app_name      = "MyApp"
    backend       = "myapp"  # References key from backends map
    redirect_uris = ["https://myapp.example.com", "http://localhost:3000"]
    owners = [
      "00000000-0000-0000-0000-000000000000",  # Primary owner object ID
      "11111111-1111-1111-1111-111111111111"   # Deputy owner object ID
    ]
  }
}
```

This creates:
- `MyApp-Backend-DEV` (backend API)
- `MyApp-Frontend-DEV` (SPA)

### Multiple SPAs per Backend

You can have multiple SPAs sharing the same backend API:

```hcl
backends = {
  portal = {
    app_name           = "Portal"
    create_role_groups = true
    owners             = ["...", "..."]
  }
}

spas = {
  portal-web = {
    app_name      = "Portal"
    backend       = "portal"
    redirect_uris = ["https://portal.example.com"]
    owners        = ["...", "..."]
  }
  portal-admin = {
    app_name      = "PortalAdmin"
    backend       = "portal"
    redirect_uris = ["https://admin.portal.example.com"]
    owners        = ["...", "..."]
  }
}
```

This creates:
- `Portal-Backend-DEV`
- `Portal-Frontend-DEV`
- `PortalAdmin-Frontend-DEV`

### Custom App Roles

Override the default roles (user, viewer, admin):

```hcl
backends = {
  billing = {
    app_name = "Billing"
    owners   = ["...", "..."]
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

### Backend-to-Backend Access (Client Credential Flow)

For service-to-service communication without user context:

```hcl
backends = {
  billing = {
    app_name = "Billing"
    owners   = ["...", "..."]
  }

  scheduler = {
    app_name = "Scheduler"
    owners   = ["...", "..."]
    # This backend can call the billing API with the specified roles
    target_backends = {
      billing = {
        roles = ["reader"]
      }
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

## Required Configuration

| Variable | Requirement |
|----------|-------------|
| `owners` | Minimum 2 owners required (primary + deputy) |

### Finding User Object IDs

To find user object IDs for the owner configuration:

```bash
# List all users with their object IDs
az ad user list --query "[].{Name:displayName, ObjectId:id}" -o table

# Search for a specific user
az ad user show --id alice@yourtenant.onmicrosoft.com --query "{Name:displayName, ObjectId:id}"

# Get your own user ID
az ad signed-in-user show --query id -o tsv
```

## Optional Features

| Feature | Variable | Default | Requirement |
|---------|----------|---------|-------------|
| Create test groups | `create_role_groups` | false | - |
| Custom app roles | `app_roles` | user/viewer/admin | - |
| Claims mapping | `enable_claims_mapping` | false | Azure AD Premium |
| Backend-to-backend | `target_backends` | - | - |

## Client Secrets

Client secrets are not managed by Terraform. Create them manually in the Azure Portal under "Certificates & secrets". See the [backend module README](modules/backend-app-registration/README.md#client-secrets) for rationale.

## Cost

All default features are **free**. Only `enable_claims_mapping` requires Azure AD Premium.
