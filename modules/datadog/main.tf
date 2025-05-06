data "aws_caller_identity" "current" {}

resource "datadog_integration_aws_external_id" "datadog" {}

resource "datadog_integration_aws_account" "datadog_integration" {
  provider       = datadog.correct
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_partition  = "aws"

  aws_regions {
    include_all = true
  }

  auth_config {
    aws_auth_config_role {
      role_name = var.datadog_role_name
    }
  }

  resources_config {
    cloud_security_posture_management_collection = true
    extended_collection                          = true
  }

  traces_config {
    xray_services {
    }
  }

  logs_config {
    lambda_forwarder {
    }
  }
  metrics_config {
    namespace_filters {
    }
  }
}
