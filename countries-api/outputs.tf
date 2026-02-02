output "synthetic_test_id" {
  description = "The ID of the synthetic test"
  value       = datadog_synthetics_test.countries_api_health_check.id
}

output "slo_id" {
  description = "The ID of the SLO"
  value       = datadog_service_level_objective.countries_api_health_check_slo.id
}
