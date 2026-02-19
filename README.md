# Terraform Actions Demo: DynamoDB Backup + SNS Publish + CloudWatch Logs

This repo demonstrates **Terraform Actions** as **Day-2 operations**:

- Create an **on-demand backup** of a DynamoDB table
- **Publish a message** to an SNS topic
- **Write an operational log line to CloudWatch Logs** by invoking a small logger Lambda

It also includes an optional **lifecycle-triggered workflow**: when you bump `release_version`,
Terraform will automatically run all three actions (backup + notify + log).

## Prerequisites
- Terraform **>= 1.14.0**
- AWS credentials configured locally
- Permissions to create/manage:
  - DynamoDB table + backups
  - SNS topic (+ optional subscription)
  - SSM Parameter
  - Lambda + CloudWatch Logs

## Quick start

### 1) Init + apply
```bash
terraform init
terraform apply
```

### 2) (Optional) Subscribe an email to SNS
Confirm the subscription from your inbox.
```bash
terraform apply -var='email=you@example.com'
```

### 3) Run the automated release workflow (recommended “wow” moment)
```bash
terraform apply -var='release_version=v2'
```

**Proof:**
- DynamoDB console → table → Backups tab (new on-demand backup)
- SNS: email (if confirmed) or console metrics
- CloudWatch Logs: log group `/aws/lambda/<project>-ops-logger` contains a log line

### 4) Watch CloudWatch logs from CLI
```bash
LOG_GROUP=$(terraform output -raw logger_log_group)
aws logs tail "$LOG_GROUP" --since 10m --follow
```

### 5) Manual Day-2 runbook actions (on demand)

Create a backup:
```bash
terraform apply -invoke='action.aws_dynamodb_create_backup.on_demand'
```

Publish a message:
```bash
terraform apply -invoke='action.aws_sns_publish.notify_manual' -var='message=Backup completed. Ready for change.'
```

Write a CloudWatch log line:
```bash
terraform apply -invoke='action.aws_lambda_invoke.write_log'
```

### 6) Disable automatic triggers (optional)
```bash
terraform apply -var='enable_release_workflow=false'
```

## Cleanup
```bash
terraform destroy
```
