resource "aws_wafv2_web_acl" "cloudfront_waf" {
  name  = "${var.projectname}-cdn-waf-${var.environment}"
  scope = local.waf_scope

  default_action {
    allow {}
  }

  rule {
    name     = local.managed_rule_name
    priority = local.rule_priority

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = local.managed_rule_name
        vendor_name = local.managed_rule_vendor
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = local.rule_metric_name
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = local.web_acl_metric_name
    sampled_requests_enabled   = true
  }

  tags = {
    Environment = var.environment
  }
}