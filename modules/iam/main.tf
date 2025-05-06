data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# EC2 Role
resource "aws_iam_role" "wordpress_role" {
  name               = "${var.projectname}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = {
    Name        = "${var.projectname}-ec2-role"
    Environment = var.environment
  }
}

# Policy
resource "aws_iam_policy" "rds_and_secret_access" {
  name   = "${var.projectname}-secrets-access"
  policy = data.aws_iam_policy_document.rds_and_secret_manager.json
}

# Policy Attachment
resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
  role       = aws_iam_role.wordpress_role.name
  policy_arn = aws_iam_policy.rds_and_secret_access.arn
}

# Instance Profile
resource "aws_iam_instance_profile" "wordpress_profile" {
  name = "${var.projectname}-instance-profile"
  role = aws_iam_role.wordpress_role.name
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = var.lambda_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}


data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "rds_and_secret_manager" {
  statement {
    actions = [
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeMountTargets"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = ["rds:DescribeDBInstances"]
    resources = ["*"]
    effect = "Allow"
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:rds*"
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "flow_log_policy" {
  name        = "${var.projectname}-flow-log-policy"
  description = "Policy for VPC Flow Logs to write to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc/${var.projectname}-${var.environment}-flowlogs:*"
      }
    ]
  })

  tags = {
    Name        = "${var.projectname}-flow-log-policy"
    Environment = var.environment
  }
}


data "aws_iam_policy_document" "flow_log_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "flow_log_role" {
  name               = "${var.projectname}-flow-log-role"
  assume_role_policy = data.aws_iam_policy_document.flow_log_assume_role.json

  tags = {
    Name        = "${var.projectname}-flow-log-role"
    Environment = var.environment
  }
}


resource "aws_iam_role_policy_attachment" "flow_log_policy_attachment" {
  role       = aws_iam_role.flow_log_role.name
  policy_arn = aws_iam_policy.flow_log_policy.arn
}


resource "aws_iam_role_policy" "lambda_edge_logs" {
  name = "${var.projectname}-lambda-edge-logs"
  role = aws_iam_role.lambda_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = [
          "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/lambda_edge:*",
          "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.lambda_edge_fuction}-*:*"
        ]
      }
    ]
  })
}

#Lambda Role with additional permissions 
resource "aws_iam_role_policy" "lambda_additional_permissions" {
  name = "${var.projectname}-lambda-additional-permissions"
  role = aws_iam_role.lambda_role.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "logs:CreateLogGroup",
          "logs:PutLogEvents"
        ],
        Resource = [
          "${var.cloudfront_logs_bucket_arn}/*",
          "${var.alb_logs_bucket_arn}/*"
        ]
      }
    ]
  })
}


resource "aws_iam_policy" "datadog_forwarder_lambda_policy" {
  name        = "${var.projectname}-datadog-forwarder-policy"
  description = "Policy for Datadog Forwarder Lambda to read S3 logs and write CloudWatch logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams"
        ],
        Resource = [
          "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/datadog-forwarder:*",
          "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.datadog_function}-*:*"
        ]
      },

      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:GetObjectVersion"
        ],
        Resource = [
          "${var.cloudfront_logs_bucket_arn}/*",
          "${var.alb_logs_bucket_arn}/*"
        ]
      }
    ]
  })
}

# S3 Bucket Policies Section
# --------------------------

# CloudFront Logs Bucket Policy
data "aws_iam_policy_document" "cloudfront_logs_policy" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${var.cloudfront_logs_bucket_name}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${var.cloudfront_distribution_id}"]
    }
  }
}

# ALB Logs Bucket Policy
data "aws_iam_policy_document" "alb_logs_policy" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${var.alb_logs_bucket_name}/*"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
  }
}

data "aws_elb_service_account" "main" {}


# EC2 Access Policy
resource "aws_iam_policy" "s3_logs_access" {
  name        = "${var.projectname}-s3-logs-access"
  description = "Allows EC2 instances to access log buckets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.cloudfront_logs_bucket_name}",
          "arn:aws:s3:::${var.cloudfront_logs_bucket_name}/*",
          "arn:aws:s3:::${var.alb_logs_bucket_name}",
          "arn:aws:s3:::${var.alb_logs_bucket_name}/*"
        ]
      }
    ]
  })
}

data "aws_iam_policy_document" "datadog_aws_integration_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::464622532012:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.external_id]
    }
  }
}

resource "aws_iam_role" "datadog_aws_integration" {
  name               = "DatadogAWSIntegrationRole"
  description        = "Role for Datadog AWS Integration"
  assume_role_policy = data.aws_iam_policy_document.datadog_aws_integration_assume_role.json
}

resource "aws_iam_policy" "datadog_aws_integration" {
  name   = "DatadogAWSIntegrationPolicy"
  policy = file("${path.module}/datadog_permissions_policy.json")
}

resource "aws_iam_role_policy_attachment" "datadog_aws_integration" {
  role       = aws_iam_role.datadog_aws_integration.name
  policy_arn = aws_iam_policy.datadog_aws_integration.arn
}

resource "aws_iam_role_policy_attachment" "datadog_aws_integration_security_audit" {
  role       = aws_iam_role.datadog_aws_integration.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}


data "aws_iam_policy_document" "central_logs_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${var.projectname}-${var.environment}-central-access-logs-${var.aws_account_id}/*"]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:s3:::${var.projectname}-${var.environment}-cloudfront-logs-${var.aws_account_id}",
        "arn:aws:s3:::${var.projectname}-${var.environment}-alb-logs-${var.aws_account_id}",
      ]
    }
  }
}


resource "aws_iam_role_policy_attachment" "datadog_forwarder_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.datadog_forwarder_lambda_policy.arn
}