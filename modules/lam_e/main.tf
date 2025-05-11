resource "aws_lambda_function" "edge_lambda" {
  function_name = var.lambda_name
  role          = var.lambda_role_arn
  filename      = local.edge_lambda_filename
  handler       = local.edge_lambda_handler
  runtime       = local.edge_lambda_runtime
  publish       = true
  timeout       = local.edge_lambda_timeout
  memory_size   = local.edge_lambda_memory_size

  source_code_hash = filebase64sha256(local.edge_lambda_filename)

}

resource "aws_lambda_permission" "allow_cloudfront" {
  statement_id  = local.statement_id_cloudfront
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.edge_lambda.function_name
  principal     = local.permission_cloudfront_principal
  source_arn    = var.cloudfront_distribution_arn
}

resource "aws_lambda_function" "datadog_forwarder" {
  function_name = local.datadog_lambda_name
  description   = local.datadog_lambda_description
  role          = var.lambda_role_arn
  handler       = local.datadog_lambda_handler
  runtime       = local.datadog_lambda_runtime
  memory_size   = local.datadog_lambda_memory_size
  timeout       = local.datadog_lambda_timeout

  filename         = local.datadog_lambda_filename
  source_code_hash = filebase64sha256(local.datadog_lambda_filename)

  environment {
    variables = {
      DD_API_KEY       = var.datadog_api_key
      DD_SITE          = "datadoghq.com"
      DD_FORWARDER_LOG = "true"
    }
  }
}

resource "aws_lambda_permission" "allow_s3_to_invoke" {
  statement_id  = local.statement_id_s3_logs
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.datadog_forwarder.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.cloudfront_logs_bucket_arn
}

resource "aws_lambda_permission" "allow_alb_logs_s3" {
  statement_id  = local.statement_id_alb_logs
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.datadog_forwarder.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.alb_logs_bucket_arn
}