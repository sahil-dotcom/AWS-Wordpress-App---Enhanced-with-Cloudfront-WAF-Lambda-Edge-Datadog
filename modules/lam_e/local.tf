locals {
  edge_lambda_filename    = "${path.module}/lambda_function.zip"
  edge_lambda_handler     = "lambda_function.lambda_handler"
  edge_lambda_runtime     = "python3.9"
  edge_lambda_timeout     = 5
  edge_lambda_memory_size = 128

  datadog_lambda_name        = "datadog-forwarder"
  datadog_lambda_description = "Datadog's serverless log forwarder"
  datadog_lambda_handler     = "lambda_function.lambda_handler"
  datadog_lambda_runtime     = "python3.11"
  datadog_lambda_memory_size = 256
  datadog_lambda_timeout     = 300
  datadog_lambda_filename    = "${path.module}/aws-dd-forwarder.zip"

  permission_cloudfront_principal = "edgelambda.amazonaws.com"
  permission_s3_principal         = "s3.amazonaws.com"
  statement_id_cloudfront         = "AllowExecutionFromCloudFront"
  statement_id_s3_logs            = "AllowExecutionFromS3Bucket"
  statement_id_alb_logs           = "AllowExecutionFromALBLogsBucket"
}
