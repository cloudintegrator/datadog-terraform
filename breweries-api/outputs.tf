output "synthetic_test_id" {
  description = "The ID of the synthetic test"
  value       = datadog_synthetics_test.breweries_api_health_check.id
}

output "slo_id" {
  description = "The ID of the SLO"
  value       = datadog_service_level_objective.breweries_api_health_check_slo.id
}
