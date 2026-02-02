# Building Reusable Datadog Monitoring Infrastructure with Terraform

Managing application health checks and SLOs (Service Level Objectives) across multiple APIs can quickly become a maintenance nightmare. In this article, I'll walk you through how to create a modular, reusable Terraform configuration for Datadog synthetic tests and SLOs.

## The Problem

Imagine you have multiple APIs that need health monitoring. For each API, you need:
- A synthetic health check that runs periodically
- An SLO to track availability over time
- Consistent tagging and alerting

Manually creating these in the Datadog UI is error-prone and doesn't scale. Copy-pasting Terraform code for each API leads to duplication and drift.

## The Solution: Modular Terraform

We'll create a modular Terraform structure where each API has its own module, but shares a common pattern. This gives us:
- **Reusability**: Add a new API by copying a module and updating a few values
- **Consistency**: All APIs follow the same monitoring pattern
- **Maintainability**: Update the pattern once, apply everywhere

## Project Structure

```
datadog-terraform/
├── main.tf                 # Module declarations
├── provider.tf             # Datadog provider configuration
├── variables.tf            # Root variable definitions
├── terraform.tfvars        # Variable values (credentials, URLs, names)
├── breweries-api/          # API module
│   ├── health-check.tf
│   ├── slo.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── versions.tf
└── countries-api/          # API module
    ├── health-check.tf
    ├── slo.tf
    ├── variables.tf
    ├── outputs.tf
    └── versions.tf
```

## Step 1: Configure the Provider

First, set up the Datadog provider in `provider.tf`:

```hcl
terraform {
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.39"
    }
  }
}

provider "datadog" {
  api_key  = var.datadog_api_key
  app_key  = var.datadog_app_key
  api_url  = "https://api.us5.datadoghq.com/"
  validate = false
}
```

## Step 2: Define Root Variables

In `variables.tf`, define the structure for API credentials:

```hcl
variable "datadog_api_key" {
  description = "Datadog API key"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Datadog Application key"
  type        = string
  sensitive   = true
}

variable "api_credentials" {
  description = "API credentials map keyed by environment and API name"
  type = map(map(object({
    client_id              = string
    client_secret          = string
    url                    = string
    health_check_test_name = string
    slo_name               = string
  })))
  sensitive = true
}
```

This structure allows you to organize credentials by environment (qa, staging, prod) and API name.

## Step 3: Create the API Module

Each API module contains four key files:

### health-check.tf

```hcl
resource "datadog_synthetics_test" "breweries_api_health_check" {
  name      = var.health_check_test_name
  type      = "api"
  subtype   = "http"
  status    = "live"
  message   = "Health check failed for breweries-api-q1"
  locations = ["aws:us-east-1", "aws:us-west-2", "aws:eu-west-1"]

  tags = [
    "env:qa",
    "service:breweries-api",
    "team:Mule"
  ]

  request_definition {
    method = "GET"
    url    = var.url
  }

  request_basicauth {
    username = var.client_id
    password = var.client_secret
  }

  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }

  assertion {
    type     = "responseTime"
    operator = "lessThan"
    target   = "5000"
  }

  options_list {
    tick_every = 300  # Check every 5 minutes

    retry {
      count    = 2
      interval = 300
    }

    monitor_options {
      renotify_interval = 120
    }
  }
}
```

### slo.tf

```hcl
resource "datadog_service_level_objective" "breweries_api_health_check_slo" {
  name        = var.slo_name
  type        = "monitor"
  description = "SLO tracking the availability of breweries-api health check endpoint"

  monitor_ids = [datadog_synthetics_test.breweries_api_health_check.monitor_id]

  thresholds {
    timeframe = "7d"
    target    = 99.9
    warning   = 99.95
  }

  thresholds {
    timeframe = "30d"
    target    = 99.9
    warning   = 99.95
  }

  thresholds {
    timeframe = "90d"
    target    = 99.9
    warning   = 99.95
  }

  tags = [
    "env:qa",
    "service:breweries-api",
    "team:Mule"
  ]
}
```

### variables.tf (module)

```hcl
variable "client_id" {
  description = "Client ID for basic auth"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Client secret for basic auth"
  type        = string
  sensitive   = true
}

variable "url" {
  description = "Health check URL"
  type        = string
  sensitive   = true
}

variable "health_check_test_name" {
  description = "Name of the health check test"
  type        = string
}

variable "slo_name" {
  description = "Name of the SLO"
  type        = string
}
```

### outputs.tf

```hcl
output "synthetic_test_id" {
  description = "The ID of the synthetic test"
  value       = datadog_synthetics_test.breweries_api_health_check.id
}

output "slo_id" {
  description = "The ID of the SLO"
  value       = datadog_service_level_objective.breweries_api_health_check_slo.id
}
```

## Step 4: Wire Up the Modules

In `main.tf`, instantiate each module:

```hcl
module "breweries_api" {
  source = "./breweries-api"

  client_id              = var.api_credentials["qa"]["breweries-api"].client_id
  client_secret          = var.api_credentials["qa"]["breweries-api"].client_secret
  url                    = var.api_credentials["qa"]["breweries-api"].url
  health_check_test_name = var.api_credentials["qa"]["breweries-api"].health_check_test_name
  slo_name               = var.api_credentials["qa"]["breweries-api"].slo_name
}

module "countries_api" {
  source = "./countries-api"

  client_id              = var.api_credentials["qa"]["countries-api"].client_id
  client_secret          = var.api_credentials["qa"]["countries-api"].client_secret
  url                    = var.api_credentials["qa"]["countries-api"].url
  health_check_test_name = var.api_credentials["qa"]["countries-api"].health_check_test_name
  slo_name               = var.api_credentials["qa"]["countries-api"].slo_name
}

output "breweries_api_synthetic_test_id" {
  description = "The ID of the breweries-api synthetic test"
  value       = module.breweries_api.synthetic_test_id
}

output "breweries_api_slo_id" {
  description = "The ID of the breweries-api SLO"
  value       = module.breweries_api.slo_id
}
```

## Step 5: Configure Your APIs

In `terraform.tfvars`, define your API configurations:

```hcl
datadog_api_key = "your-api-key"
datadog_app_key = "your-app-key"

api_credentials = {
  "qa" = {
    "breweries-api" = {
      client_id              = "your-client-id"
      client_secret          = "your-client-secret"
      url                    = "https://api.openbrewerydb.org/v1/breweries"
      health_check_test_name = "[TF][breweries-api] Health Check Test"
      slo_name               = "[TF][breweries-api] Health Check Availability"
    }
    "countries-api" = {
      client_id              = "your-client-id"
      client_secret          = "your-client-secret"
      url                    = "https://restcountries.com/v3.1/name/brazil"
      health_check_test_name = "[TF][countries-api] Health Check Test"
      slo_name               = "[TF][countries-api] Health Check Availability"
    }
  }
}
```

## Usage

### Initialize and Apply

```bash
terraform init
terraform plan
terraform apply
```

### Target Specific Modules

```bash
# Apply only breweries-api
terraform apply -target=module.breweries_api

# Destroy only countries-api
terraform destroy -target=module.countries_api
```

## Adding a New API

1. Create a new folder (e.g., `users-api/`)
2. Copy files from an existing module
3. Update resource names in the new module
4. Add the module declaration in `main.tf`
5. Add credentials in `terraform.tfvars`
6. Run `terraform init` and `terraform apply`

## Best Practices

1. **Use sensitive = true**: Mark credentials as sensitive to prevent them from appearing in logs
2. **Consistent naming**: Use a naming convention like `[TF][api-name] Resource Type`
3. **Tag everything**: Tags help with cost allocation and filtering in Datadog
4. **Version control**: Keep your Terraform code in Git (but not `terraform.tfvars` with real credentials!)
5. **Use workspaces or separate state files**: For managing multiple environments

## Conclusion

By using Terraform modules for Datadog monitoring, you can:
- Maintain consistency across all your APIs
- Quickly onboard new services
- Version control your monitoring infrastructure
- Review changes through pull requests before applying

The modular approach scales well whether you have 2 APIs or 200. The initial setup takes some time, but the long-term maintenance benefits are worth it.

---

*Found this helpful? Follow me for more DevOps and infrastructure-as-code content.*
