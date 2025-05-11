resource "aws_cloudfront_distribution" "wordpress_distribution" {
  web_acl_id = var.waf_acl_arn
  origin {
    domain_name = var.alb_dns_name
    origin_id   = "${var.projectname}-ALB-C"

    custom_origin_config {
      http_port                = local.origin_http_port
      https_port               = local.origin_https_port
      origin_protocol_policy   = local.origin_protocol_policy
      origin_ssl_protocols     = local.origin_ssl_protocols
      origin_read_timeout      = local.origin_read_timeout
      origin_keepalive_timeout = local.origin_keepalive_timeout
    }
  }


  enabled             = true
  default_root_object = "/"
  is_ipv6_enabled     = true
  comment             = local.cloudfront_comment

  aliases = [var.domain_name]

  default_cache_behavior {
    origin_request_policy_id = aws_cloudfront_origin_request_policy.forward_all_header.id
    cache_policy_id          = aws_cloudfront_cache_policy.custom_cache_policy.id
    target_origin_id         = "${var.projectname}-ALB-C"
    viewer_protocol_policy   = local.viewer_protocol_policy
    allowed_methods          = local.allowed_methods
    cached_methods           = local.cached_methods
    compress                 = true
  }


  price_class = local.price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = local.ssl_support_method
    minimum_protocol_version = local.minimum_protocol_version
  }

  logging_config {
    include_cookies = false
    bucket          = var.cloudfront_bucket_name
    prefix          = local.logging_prefix
  }

}

resource "aws_cloudfront_cache_policy" "custom_cache_policy" {
  name = "wordpress-custom-cache-policy"

  default_ttl = local.cache_policy_default_ttl
  max_ttl     = local.cache_policy_max_ttl
  min_ttl     = local.cache_policy_min_ttl

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    headers_config {
      header_behavior = "none"
    }

    cookies_config {
      cookie_behavior = "whitelist"
      cookies {
        items = [
          "wordpress_logged_in_*",
          "wordpress_sec_*",
          "wordpress_test_cookie",
          "wp-settings-*",
          "wp-settings-time-*"
        ]
      }
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "forward_all_header" {
  name = "forward-host-header-policy"

  headers_config {
    header_behavior = "whitelist"
    headers {
      items = [
        "Host",
        "X-Forwarded-For"
      ]
    }
  }

  cookies_config {
    cookie_behavior = "all"
  }

  query_strings_config {
    query_string_behavior = "all"
  }
}