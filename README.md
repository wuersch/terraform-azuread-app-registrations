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
│   └── prod/                    # Production tenant
```

## Quick Start

```bash
# Authenticate to Azure
az login

# Deploy to DEV stage
cd environments/test
terraform init
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars

# Destroy when done testing
terraform destroy -var-file=dev.tfvars
```

## Environments

| Environment | Stages | State Backend | Description |
|-------------|--------|---------------|-------------|
| test | DEV, INT, PREPROD, PREPROD02 | Local (personal) / Azure blob (corporate) | Test tenant |
| prod | PROD | Azure blob | Production tenant |

## Configuration

### Stage-specific tfvars

Create `<stage>.tfvars` files for each stage:

```hcl
# int.tfvars
environment = "int"
app_name    = "MyApp"

spa_redirect_uris = [
  "https://myapp-int.company.com"
]

role_group_assignments = {
  user   = "group-object-id"
  admin  = "group-object-id"
}
```

### Multiple Applications

Deploy multiple SPA/API pairs in the same environment:

```hcl
# main.tf
module "portal_api" {
  source       = "../../modules/api-app-registration"
  display_name = "Customer Portal API"
}

module "portal_spa" {
  source        = "../../modules/spa-app-registration"
  display_name  = "Customer Portal SPA"
  api_client_id = module.portal_api.application_id
  api_scope_id  = module.portal_api.oauth2_scope_ids["user_access"]
  # ...
}

module "dashboard_api" {
  source       = "../../modules/api-app-registration"
  display_name = "Internal Dashboard API"
}

module "dashboard_spa" {
  source        = "../../modules/spa-app-registration"
  display_name  = "Internal Dashboard SPA"
  api_client_id = module.dashboard_api.application_id
  api_scope_id  = module.dashboard_api.oauth2_scope_ids["user_access"]
  # ...
}
```

## Outputs

### MSAL.js Configuration (Frontend)

```bash
terraform output -json msal_config
```

```json
{
  "auth": {
    "clientId": "xxx",
    "authority": "https://login.microsoftonline.com/xxx",
    "redirectUri": "http://localhost:3000"
  },
  "api": {
    "scopes": ["api://xxx/user_access"]
  }
}
```

### Spring Boot Configuration (Backend)

```bash
terraform output -json spring_boot_config
```

## Security Features

- **PKCE**: Authorization Code flow with PKCE (no client secrets for SPA)
- **No implicit flow**: Explicitly disabled
- **Admin consent**: API scope requires admin consent
- **App roles**: user, viewer, admin roles with group assignments

## Optional Features

| Feature | Variable | Default | Requirement |
|---------|----------|---------|-------------|
| Create test groups | `create_role_groups` | false | - |
| Claims mapping (sAMAccountName) | `enable_claims_mapping` | false | Azure AD Premium |
| Client secret for API | `create_client_secret` | false | - |

## Cost

All default features are **free**. Only `enable_claims_mapping` requires Azure AD Premium.
