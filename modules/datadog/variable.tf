variable "dashboard_title" {
  description = "Name of the Datadog dashboard"
  type        = string
}

variable "datadog_api_key" {
  type = string
}

variable "datadog_app_key" {
  type = string
}

variable "datadog_role_name" {
  description = "The name of the IAM role used for Datadog integration"
  type        = string
}

variable "datadog_role_arn" {
  description = "The ARN of the IAM role used for Datadog integration"
  type        = string
}