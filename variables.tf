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
    client_id           = string
    client_secret       = string
    url                 = string
    health_check_test_name = string
    slo_name            = string
  })))
  sensitive = true
}
