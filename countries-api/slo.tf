resource "datadog_service_level_objective" "countries_api_health_check_slo" {
  name        = var.slo_name
  type        = "monitor"
  description = "SLO tracking the availability of countries-api health check endpoint"

  monitor_ids = [datadog_synthetics_test.countries_api_health_check.monitor_id]

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
    "service:countries-api",
    "team:Mule"
  ]
}
