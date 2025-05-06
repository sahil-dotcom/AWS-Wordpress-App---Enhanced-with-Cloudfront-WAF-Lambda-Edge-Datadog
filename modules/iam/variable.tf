variable "projectname" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, prod, etc.)"
  type        = string
}

variable "lambda_role_name" {
  description = "IAM Role Name for Lambda function"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the RDS secret in Secrets Manager"
  type        = string
}

variable "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  type        = string
}

variable "cloudfront_logs_bucket_name" {
  type = string
}

variable "alb_logs_bucket_name" {
  type = string
}

# variable "waf_logs_bucket_name" {
#   type = string
# }

variable "external_id" {
  type = string
}

variable "datadog_role_name" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "datadog_account_id" {
  description = "The AWS Account ID used by Datadog to assume the IAM role"
  type        = string
}

variable "alb_logs_bucket_arn" {
  description = "alb log bucket arn"
  type        = string
}

variable "cloudfront_logs_bucket_arn" {
  description = "cloudfront log bucket arn"
  type        = string
}

variable "lambda_edge_fuction" {
  description = "lambda edge function name"
  type        = string
}

variable "datadog_function" {
  description = "datadog function name"
  type        = string
}