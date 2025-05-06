output "lambda_arn" {
  value = aws_lambda_function.edge_lambda.qualified_arn
}

output "lambda_version" {
  value = aws_lambda_function.edge_lambda.version
}

output "datadatadog_forwarder_lambda_arn" {
  value = aws_lambda_function.datadog_forwarder.arn
}