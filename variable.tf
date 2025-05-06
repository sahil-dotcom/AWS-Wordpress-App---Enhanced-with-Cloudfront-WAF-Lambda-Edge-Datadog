variable "aws_region" {
  description = "aws region"
  type        = string
}
variable "projectname" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "default-route" {
  description = "default"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "db_name" {
  description = "Name of the RDS database"
  type        = string
}

variable "db_username" {
  description = "Username for the RDS database"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_storage_size" {
  description = "RDS storage size in GB"
  type        = number
}

variable "db_engine_version" {
  description = "RDS MySQL engine version"
  type        = string
}

variable "db_engine" {
  description = "Database Engine Type"
  type        = string
}

variable "db_storage_type" {
  description = "Database Storage Type"
  type        = string
}

variable "load_balancer_type" {
  description = "Type of LoadBalancer"
  type        = string
}

variable "min_size" {
  description = "Minimum size for ASG"
  type        = number
}

variable "max_size" {
  description = "Maximum size for ASG"
  type        = number
}

variable "desired_capacity" {
  description = "Desired capacity for ASG"
  type        = number
}

variable "alb_instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "domain_name" {
  description = "The domain name for the WordPress application"
  type        = string
}

variable "lambda_name" {
  type = string
}

variable "lambda_role_name" {
  description = "Name of the IAM role for Lambda@Edge"
  type        = string
}

variable "waf_name" {
  type = string
}

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

variable "aws_account_id" {
  type = string
}

variable "datadog_role_name" {
  default     = "DatadogIntegrationRole"
  description = "Name of the IAM Role for Datadog"
}

variable "dashboard_title" {
  type = string
}

variable "datadog_account_id" {
  type = string
}

variable "datadog_function" {
  type = string
}

