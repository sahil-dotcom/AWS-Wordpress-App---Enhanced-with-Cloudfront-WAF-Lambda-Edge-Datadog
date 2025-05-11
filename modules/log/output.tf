output "cloudfront_logs_bucket" {
  description = "CloudFront logs bucket name"
  value       = aws_s3_bucket.cloudfront_logs.id
}

output "alb_logs_bucket" {
  description = "alb logs bucket name"
  value       = aws_s3_bucket.alb_logs.id
}

output "cloudfront_logs_bucket_arn" {
  description = "ARN of the CloudFront logs bucket"
  value       = aws_s3_bucket.cloudfront_logs.arn
}

output "alb_logs_bucket_arn" {
  description = "ARN of the ALB logs bucket"
  value       = aws_s3_bucket.alb_logs.arn
}

output "cloudfront_logs_buckets" {
  description = "CloudFront logs bucket domain name"
  value       = aws_s3_bucket.cloudfront_logs.bucket_domain_name
}