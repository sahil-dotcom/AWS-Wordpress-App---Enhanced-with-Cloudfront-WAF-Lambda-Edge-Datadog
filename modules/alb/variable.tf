variable "projectname" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "load_balancer_type" {
  description = "Type of LoadBalancer"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for ALB"
  type        = list(string)
}

variable "security_groups" {
  description = "Security group IDs for ALB"
  type        = list(string)
}

variable "acm_certificate_arn" {
  type = string
}

variable "log_bucket" {
  description = "Name of the S3 bucket for ALB access logs"
  type        = string
}