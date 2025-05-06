variable "environment" {
  type = string
}

variable "domain_name" {
  description = "The domain name for the WordPress application"
  type        = string
}

variable "hosted_zone_id" {
  description = "The Hosted Zone ID from Route 53"
  type        = string
}

variable "cloudfront_distribution_domain_name" {
  description = "The domain name of the CloudFront distribution"
  type        = string
}

variable "cloudfront_hosted_zone_id" {
  description = "The hosted zone ID for CloudFront"
  type        = string
}
