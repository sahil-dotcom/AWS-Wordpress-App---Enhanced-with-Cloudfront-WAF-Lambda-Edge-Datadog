locals {
  waf_scope           = "CLOUDFRONT"
  managed_rule_name   = "AWSManagedRulesCommonRuleSet"
  managed_rule_vendor = "AWS"
  rule_priority       = 1
  rule_metric_name    = "AWSManagedRulesCommonRuleSet"
  web_acl_metric_name = "cloudfront-waf-metrics"
}
