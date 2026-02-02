variable "client_id" {
  description = "Client ID for API authentication"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Client secret for API authentication"
  type        = string
  sensitive   = true
}

variable "url" {
  description = "Health check endpoint URL"
  type        = string
}

variable "health_check_test_name" {
  description = "Name of the health check test"
  type        = string
}

variable "slo_name" {
  description = "Name of the SLO"
  type        = string
}
