output "cloudfront_waf_arn" {
  description = "ARN of the CloudFront WAF"
  value       = aws_wafv2_web_acl.cloudfront_waf.arn
}

output "cloudfront_waf_id" {
  description = "ID of the CloudFront WAF"
  value       = aws_wafv2_web_acl.cloudfront_waf.id
}