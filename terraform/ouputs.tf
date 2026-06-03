output "s3_bucket_name" {
  value       = aws_s3_bucket.incident_reports.bucket
  description = "S3 bucket storing AI incident reports"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.incidents.name
  description = "DynamoDB table storing incident records"
}

output "sns_topic_arn" {
  value       = aws_sns_topic.incident_alerts.arn
  description = "SNS topic for incident notifications"
}

output "lambda_function_name" {
  value       = aws_lambda_function.incident_triage.function_name
  description = "Lambda function for AI incident triage"
}