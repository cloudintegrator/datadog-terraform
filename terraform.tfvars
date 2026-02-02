datadog_api_key = "xxxx"
datadog_app_key = "xxxx"

api_credentials = {
  "qa" = {
    "breweries-api" = {
      client_id           = "xxxx"
      client_secret       = "xxxx"
      url                 = "https://api.openbrewerydb.org/v1/breweries"
      health_check_test_name = "[TF][breweries-api] Health Check Test"
      slo_name            = "[TF][breweries-api] Health Check Availability"
    }
    "countries-api" = {
      client_id           = "xxxx"
      client_secret       = "xxxx"
      url                 = "https://restcountries.com/v3.1/name/brazil"
      health_check_test_name = "[TF][countries-api] Health Check Test"
      slo_name            = "[TF][countries-api] Health Check Availability"
    }
  }
}
