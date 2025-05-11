locals {
  origin_http_port         = 80
  origin_https_port        = 443
  origin_protocol_policy   = "https-only"
  origin_ssl_protocols     = ["TLSv1.2"]
  origin_read_timeout      = 60
  origin_keepalive_timeout = 10

  viewer_protocol_policy = "redirect-to-https"
  allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
  cached_methods         = ["GET", "HEAD", "OPTIONS"]

  price_class        = "PriceClass_100"
  cloudfront_comment = "CloudFront distribution for WordPress"

  cache_policy_default_ttl = 86400
  cache_policy_max_ttl     = 31536000
  cache_policy_min_ttl     = 0

  ssl_support_method       = "sni-only"
  minimum_protocol_version = "TLSv1.2_2021"
  logging_prefix           = "cloudfront-logs"
}
