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

output "countries_api_synthetic_test_id" {
  description = "The ID of the countries-api synthetic test"
  value       = module.countries_api.synthetic_test_id
}

output "countries_api_slo_id" {
  description = "The ID of the countries-api SLO"
  value       = module.countries_api.slo_id
}
