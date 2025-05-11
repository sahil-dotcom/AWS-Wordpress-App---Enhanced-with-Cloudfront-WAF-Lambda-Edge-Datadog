variable "projectname" {
  type = string
}

variable "environment" {
  type = string
}

variable "cloudfront_logs_policy_json" {
  description = "Bucket policy JSON for CloudFront logs"
  type        = string
}

variable "alb_logs_policy_json" {
  description = "Bucket policy JSON for ALB logs"
  type        = string
}

variable "cent_logs_policy_json" {
  description = "Bucket policy JSON for centralized logs"
  type        = string
}

variable "datadog_api_key" {
  description = "Datadog API key for log forwarding"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "vpc id"
  type        = string
}

variable "iam_role_arn" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "datadog_forwarder_lambda_arn" {
  type = string
}