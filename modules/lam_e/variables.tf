variable "lambda_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "lambda_role_arn" {
  description = "IAM role ARN for Lambda execution"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "cloudfront_distribution_arn" {
  description = "CloudFront distribution ARN"
  type        = string
}

variable "lambda_role_name" {
  type = string
}

variable "create_permission" {
  description = "Whether to create the Lambda permission"
  type        = bool
  default     = true
}

variable "datadog_api_key" {
  type = string
}

variable "cloudfront_logs_bucket_arn" {
  type = string
}

variable "alb_logs_bucket_arn" {
  type = string
}