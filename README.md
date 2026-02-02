# Datadog Terraform Configuration

This repository contains Terraform configurations for Datadog health checks and SLOs.

## Project Structure

```
tf/
├── main.tf                 # Module declarations
├── provider.tf             # Datadog provider configuration
├── variables.tf            # Root variable definitions
├── terraform.tfvars        # Variable values (credentials, URLs, names)
├── README.md
├── breweries-api/          # breweries-api API module
│   ├── health-check.tf
│   ├── slo.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── versions.tf
└── countries-api/          # countries-api API module
    ├── health-check.tf
    ├── slo.tf
    ├── variables.tf
    ├── outputs.tf
    └── versions.tf
```

## Prerequisites

- Terraform >= 1.0
- Datadog API key and App key with appropriate permissions

## Usage

### Initialize Terraform

```bash
terraform init
```

### Plan All Modules

```bash
terraform plan
```

### Apply All Modules

```bash
terraform apply
```

### Destroy All Resources

```bash
terraform destroy
```

## Targeting Specific Modules

### Plan a Specific Module

```bash
# Plan only breweries-api
terraform plan -target=module.breweries_api

# Plan only countries-api
terraform plan -target=module.countries_api
```

### Apply a Specific Module

```bash
# Apply only breweries-api
terraform apply -target=module.breweries_api

# Apply only countries-api
terraform apply -target=module.countries_api
```

### Destroy a Specific Module

```bash
# Destroy only breweries-api
terraform destroy -target=module.breweries_api

# Destroy only countries-api
terraform destroy -target=module.countries_api
```

## Targeting Specific Resources

You can also target individual resources within a module:

```bash
# Apply only the health check for breweries-api
terraform apply -target=module.breweries_api.datadog_synthetics_test.breweries_api_health_check

# Apply only the SLO for breweries-api
terraform apply -target=module.breweries_api.datadog_service_level_objective.breweries_api_health_check_slo
```

## Adding a New API

1. Create a new folder for the API (e.g., `new-api/`)
2. Copy the files from an existing module (`health-check.tf`, `slo.tf`, `variables.tf`, `outputs.tf`, `versions.tf`)
3. Update resource names in the new module
4. Add the module declaration in `main.tf`
5. Add credentials in `terraform.tfvars`

## Variable Structure

```hcl
api_credentials = {
  "<environment>" = {
    "<api-name>" = {
      client_id              = "..."
      client_secret          = "..."
      url                    = "https://..."
      health_check_test_name = "..."
      slo_name               = "..."
    }
  }
}
```

## Notes

- The `-target` flag is intended for exceptional situations (testing, troubleshooting, recovery)
- For production deployments, apply the full configuration without targeting
- Always run `terraform plan` before `terraform apply` to review changes
