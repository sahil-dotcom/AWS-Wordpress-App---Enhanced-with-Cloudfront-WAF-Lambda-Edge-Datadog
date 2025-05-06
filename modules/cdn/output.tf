output "cloudfront_distribution_arn" {
  value = aws_cloudfront_distribution.wordpress_distribution.arn
}

output "hosted_zone_id" {
  value = aws_cloudfront_distribution.wordpress_distribution.hosted_zone_id
}

output "domain_name" {
  value = aws_cloudfront_distribution.wordpress_distribution.domain_name
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.wordpress_distribution.id
}