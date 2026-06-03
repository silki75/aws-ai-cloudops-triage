data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "incident_reports" {
  bucket = "${var.project_name}-reports-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "incident_reports" {
  bucket = aws_s3_bucket.incident_reports.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "incidents" {
  name         = "${var.project_name}-incidents"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "incident_id"

  attribute {
    name = "incident_id"
    type = "S"
  }
}

resource "aws_sns_topic" "incident_alerts" {
  name = "${var.project_name}-alerts"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.incident_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/cloudops/app"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_metric_filter" "error_filter" {
  name           = "${var.project_name}-error-filter"
  log_group_name = aws_cloudwatch_log_group.app_logs.name
  pattern        = "ERROR"

  metric_transformation {
    name      = "ApplicationErrorCount"
    namespace = "CloudOpsApp"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "error_alarm" {
  alarm_name          = "${var.project_name}-error-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ApplicationErrorCount"
  namespace           = "CloudOpsApp"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggers when application errors are detected"
  alarm_actions       = [aws_sns_topic.incident_alerts.arn]
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../lambda/incident_triage.py"
  output_path = "../lambda/incident_triage.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "${var.project_name}-lambda-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:FilterLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Scan"
        ],
        Resource = aws_dynamodb_table.incidents.arn
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ],
        Resource = "${aws_s3_bucket.incident_reports.arn}/*"
      },
      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = aws_sns_topic.incident_alerts.arn
      },
      {
        Effect = "Allow",
        Action = [
          "bedrock:InvokeModel"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "incident_triage" {
  function_name = "${var.project_name}-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "incident_triage.lambda_handler"
  runtime       = "python3.11"
  filename      = data.archive_file.lambda_zip.output_path
  timeout       = 30

  environment {
    variables = {
      INCIDENT_TABLE = aws_dynamodb_table.incidents.name
      REPORT_BUCKET  = aws_s3_bucket.incident_reports.bucket
      SNS_TOPIC_ARN  = aws_sns_topic.incident_alerts.arn
    }
  }
}