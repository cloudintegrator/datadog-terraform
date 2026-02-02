resource "datadog_synthetics_test" "countries_api_health_check" {
  name      = var.health_check_test_name
  type      = "api"
  subtype   = "http"
  status    = "live"
  message   = "Health check failed for countries-api-q1"
  locations = ["aws:us-east-1", "aws:us-west-2", "aws:eu-west-1"]

  tags = [
    "env:qa",
    "service:countries-api",
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
    tick_every = 300  # Check every 5 minutes (in seconds)

    retry {
      count    = 2
      interval = 300
    }

    monitor_options {
      renotify_interval = 120
    }
  }
}
