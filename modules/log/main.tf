data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "${var.projectname}-${var.environment}-cloudfront-logs-${data.aws_caller_identity.current.account_id}"
  tags = {
    Name        = "${var.projectname}-cloudfront-logs"
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "alb_logs" {
  bucket = "${var.projectname}-${var.environment}-alb-logs-${data.aws_caller_identity.current.account_id}"
  tags = {
    Name        = "${var.projectname}-alb-logs"
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "central_access_logs" {
  bucket = "${var.projectname}-${var.environment}-central-access-logs-${data.aws_caller_identity.current.account_id}"
  tags = {
    Name        = "${var.projectname}-central-access-logs"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_ownership_controls" "logging_buckets" {
  for_each = {
    cloudfront = aws_s3_bucket.cloudfront_logs.id
    alb        = aws_s3_bucket.alb_logs.id
    central    = aws_s3_bucket.central_access_logs.id
  }

  bucket = each.value
  rule {
    object_ownership = local.object_ownership
  }
}

resource "aws_s3_bucket_acl" "logging_buckets" {
  for_each = {
    cloudfront = aws_s3_bucket.cloudfront_logs.id
    alb        = aws_s3_bucket.alb_logs.id
    central    = aws_s3_bucket.central_access_logs.id
  }

  bucket = each.value

  acl        = local.acl
  depends_on = [aws_s3_bucket_ownership_controls.logging_buckets]
}

resource "aws_s3_bucket_versioning" "logging_buckets" {
  for_each = aws_s3_bucket_ownership_controls.logging_buckets
  bucket   = each.value.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logging_buckets" {
  for_each = aws_s3_bucket_ownership_controls.logging_buckets
  bucket   = each.value.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = "alias/aws/s3"
    }
    bucket_key_enabled = true
  }
}


resource "aws_s3_bucket_logging" "service_buckets" {
  for_each = {
    cloudfront = aws_s3_bucket.cloudfront_logs.id
    alb        = aws_s3_bucket.alb_logs.id
  }

  bucket        = each.value
  target_bucket = aws_s3_bucket.central_access_logs.id
  target_prefix = "s3-logs/${each.key}/"
}

resource "aws_s3_bucket_policy" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  policy = var.cloudfront_logs_policy_json
}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = var.alb_logs_policy_json
}


resource "aws_s3_bucket_policy" "central_logs" {
  bucket = aws_s3_bucket.central_access_logs.id
  policy = var.cent_logs_policy_json
}

resource "aws_s3_bucket_public_access_block" "logging_buckets" {
  for_each = aws_s3_bucket_ownership_controls.logging_buckets
  bucket   = each.value.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_notification" "cloudfront_logs_notification" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  lambda_function {
    lambda_function_arn = var.datadog_forwarder_lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "logs/"
  }
}

resource "aws_s3_bucket_notification" "alb_logs_notification" {
  bucket = aws_s3_bucket.alb_logs.id

  lambda_function {
    lambda_function_arn = var.datadog_forwarder_lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "logs/"
  }
}


resource "aws_lambda_permission" "allow_cloudfront_bucket" {
  statement_id  = "AllowCloudfrontBucketInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "datadog-forwarder"
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.cloudfront_logs.arn
}

resource "aws_lambda_permission" "allow_alb_bucket" {
  statement_id  = "AllowALBBucketInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "datadog-forwarder"
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.alb_logs.arn
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/${var.projectname}-${var.environment}-flowlogs"
  retention_in_days = 30
  tags = {
    Name        = "${var.projectname}-vpc-flow-logs"
    Environment = var.environment
  }
}

resource "aws_flow_log" "vpc_flow_log" {
  traffic_type         = "ALL"
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  vpc_id               = var.vpc_id
  iam_role_arn         = var.iam_role_arn
}
