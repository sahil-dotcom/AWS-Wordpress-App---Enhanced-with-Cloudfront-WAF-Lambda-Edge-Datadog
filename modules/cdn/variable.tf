variable "projectname" {
  type = string
}

variable "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  type        = string
}

variable "domain_name" {
  type = string
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM Certificate for CloudFront"
  type        = string
}

variable "waf_acl_arn" {
  type = string
}

variable "lambda_arn" {
  type = string
}

variable "cloudfront_bucket_name" {
  type = string
}

variable "environment" {
  type = string
}