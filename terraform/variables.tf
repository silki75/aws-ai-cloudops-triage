variable "aws_region" {
  description = "AWS region for the project"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "ai-cloudops-triage"
}

variable "alert_email" {
  description = "Email address to receive SNS incident alerts"
  type        = string
}