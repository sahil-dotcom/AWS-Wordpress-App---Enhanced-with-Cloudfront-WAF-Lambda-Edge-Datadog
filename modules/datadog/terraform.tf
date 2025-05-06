terraform {
  required_providers {
    datadog = {
      source  = "datadog/datadog"
      version = "~> 3.0"
    }
  }
}

provider "datadog" {
  alias   = "correct"
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}