output "ec2_iam_role_arn" {
  description = "ARN of the IAM Role attached to EC2"
  value       = aws_iam_role.wordpress_role.arn
}

output "lambda_iam_role_arn" {
  description = "ARN of the IAM Role for Lambda"
  value       = aws_iam_role.lambda_role.arn
}

output "iam_instance_profile_name" {
  description = "IAM Instance Profile Name for EC2"
  value       = aws_iam_instance_profile.wordpress_profile.name
}

output "flow_log_role_arn" {
  value = aws_iam_role.flow_log_role.arn
}

output "cloudfront_logs_policy_json" {
  value = data.aws_iam_policy_document.cloudfront_logs_policy.json
}

output "alb_logs_policy_json" {
  value = data.aws_iam_policy_document.alb_logs_policy.json
}

# output "waf_logs_policy_json" {
#   value = data.aws_iam_policy_document.waf_logs_policy.json
# }

output "cent_logs_policy_json" {
  value = data.aws_iam_policy_document.central_logs_policy.json
}


output "datadog_integration_role_name" {
  value       = aws_iam_role.datadog_aws_integration.name
  description = "The name of the Datadog IAM integration role"
}

output "datadog_integration_role_arn" {
  value       = aws_iam_role.datadog_aws_integration.arn
  description = "The ARN of the Datadog IAM integration role"
}

locals {
  assume_role_policy = jsondecode(aws_iam_role.datadog_aws_integration.assume_role_policy)
}

output "datadog_integration_external_id" {
  value = local.assume_role_policy.Statement[0].Condition.StringEquals["sts:ExternalId"]
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}


