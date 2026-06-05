# AI-Powered AWS CloudOps Incident Triage Platform
## Project Overview
This project is a production-style AWS CloudOps platform that detects application errors, triggers an incident workflow, stores incident records, and sends support notifications. It demonstrates real-world DevOps, CloudOps, Infrastructure as Code, monitoring, automation, and AI-assisted incident response skills.

The project uses Terraform to provision AWS resources and GitHub Actions to validate the infrastructure code.
## Architecture
Application Logs
→ Amazon CloudWatch Logs
→ CloudWatch Metric Filter
→ CloudWatch Alarm
→ Amazon SNS Notification
→ AWS Lambda Incident Triage Function
→ Amazon DynamoDB Incident Table
→ Amazon S3 Incident Reports Bucket

## AWS Services Used
* Amazon CloudWatch Logs
* CloudWatch Metric Filters
* CloudWatch Alarms
* AWS Lambda
* Amazon SNS
* Amazon DynamoDB
* Amazon S3
* IAM
* Terraform
* GitHub Actions

## Project Structure
```text
aws-ai-cloudops-triage/
├── app/
│   ├── app.py
│   └── requirements.txt
├── lambda/
│   └── incident_triage.py
├── terraform/
│   ├── provider.tf
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── scripts/
│   └── test-incident.sh
├── docs/
├── runbooks/
├── .github/
│   └── workflows/
│       └── terraform-ci.yml
├── .gitignore
└── README.md
```

## Prerequisites
Before running this project, install and configure:
* AWS CLI
* Terraform
* Git
* Python 3
* GitHub account
* AWS account

Verify AWS access:

aws sts get-caller-identity

## Terraform Deployment
Go to the Terraform directory:
cd terraform
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply

Type `yes` when prompted.

## SNS Email Confirmation
After deployment, AWS SNS sends a confirmation email to the email address configured in Terraform.

Open the email and click **Confirm subscription**. Alerts will not work until the subscription is confirmed.

## Testing CloudWatch Logs
Create log group
aws logs create-log-group \
  --log-group-name /aws/cloudops/app
  
Create a test log stream:
aws logs create-log-stream \
  --log-group-name /aws/cloudops/app \
  --log-stream-name test-stream

Send a test error log:
aws logs put-log-events \
  --log-group-name /aws/cloudops/app \
  --log-stream-name test-stream \
  --log-events timestamp=$(date +%s000),message="ERROR database connection failed"

Tail the application logs:
aws logs tail /aws/cloudops/app --follow
```

## Testing Lambda
Find the Lambda function name:
aws lambda list-functions --query "Functions[*].FunctionName" --output table

Invoke the Lambda manually:
aws lambda invoke \
  --function-name ai-cloudops-triage-lambda \
  --payload '{}' \
  response.json


View Lambda logs:
aws logs tail /aws/lambda/ai-cloudops-triage-lambda --follow


## GitHub Actions Workflow
This project includes a GitHub Actions workflow that runs on:

* Push to the `main` branch
* Manual trigger from the GitHub Actions tab

The workflow performs:

* Repository checkout
* AWS credential configuration
* Terraform setup
* Terraform format check
* Terraform initialization
* Terraform validation
* Terraform plan

## Required GitHub Secrets
Add these secrets in GitHub:
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
ALERT_EMAIL

Path:
GitHub Repository → Settings → Secrets and variables → Actions → New repository secret
```

## Security Best Practices Demonstrated
* IAM role for Lambda
* Least-privilege IAM permissions
* Encrypted S3 bucket
* DynamoDB pay-per-request billing
* No AWS credentials committed to GitHub
* Terraform-managed infrastructure
* GitHub Secrets for sensitive values
* `.terraform/` and state files excluded from Git

## Files Not to Commit
The following should not be pushed to GitHub:
.terraform/
*.tfstate
*.tfstate.backup
terraform.tfvars

Use `terraform.tfvars.example` instead to show required variables without exposing real values.

## Cleanup

To avoid ongoing AWS charges, destroy the infrastructure when finished:

cd terraform
terraform destroy
Type `yes` when prompted.

## Summary

Built a production-style AWS AI CloudOps incident triage platform using Terraform, CloudWatch, Lambda, SNS, DynamoDB, S3, IAM, and GitHub Actions to detect application errors, trigger incident workflows, store incident records, and automate support notifications.

## Skills Demonstrated

* AWS CloudOps
* DevOps automation
* Terraform Infrastructure as Code
* CloudWatch monitoring
* Lambda serverless automation
* Incident response workflow design
* GitHub Actions CI/CD
* IAM security
* Operational troubleshooting
* Production-style documentation
