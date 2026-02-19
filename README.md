# Terraform Actions Demo: DynamoDB Backup + SNS Publish + CloudWatch Logs

This repo demonstrates **Terraform Actions** as **Day-2 operations**:

- Create an **on-demand backup** of a DynamoDB table
- **Publish a message** to an SNS topic
- **Write an operational log line to CloudWatch Logs** by invoking a small Lambda (via Terraform Action)

It also supports an optional **lifecycle-triggered workflow**: when you bump `release_version`,
Terraform can automatically run all three actions (backup + notify + log).

---

## Prerequisites

- Terraform **>= 1.14.0**
- AWS credentials configured locally (AWS_PROFILE, env vars, SSO, etc.)
- Permissions to create/manage:
  - DynamoDB table + backups
  - SNS topic (+ optional subscription)
  - SSM Parameter
  - Lambda + CloudWatch Logs


---

## Quick start

### 1) Init + apply (provision infra)
```bash
terraform init
terraform apply
```

---

## Optional: Subscribe an email to SNS

SNS email subscription requires confirmation from your inbox.

```bash
terraform apply -var='email=you@example.com'
```

---

## Run the automated release workflow

### 2) Enable the workflow (if your default is `false`)
If `enable_release_workflow` is already `true` in `variables.tf`, you can skip this step.

```bash
terraform apply -var='enable_release_workflow=true'
```

### 3) Run the automated release workflow
> This will run the Actions **only if** `enable_release_workflow` is `true` (default or provided on CLI).

```bash
terraform apply -var='release_version=v2'
```

---

## Day-2 Runbook: Manual invokes

### Create a DynamoDB on-demand backup (with release version)
```bash
terraform apply \
  -var='release_version=v2' \
  -invoke='action.aws_dynamodb_create_backup.on_demand'
```

### Publish an SNS notification (with release version)
```bash
terraform apply \
  -var='release_version=v2' \
  -invoke='action.aws_sns_publish.notify_release'
```

### Write an audit log line to CloudWatch Logs (with release version)
```bash
terraform apply \
  -var='release_version=v2' \
  -invoke='action.aws_lambda_invoke.write_log'
```

---

## Proof / Verification

### DynamoDB backup
AWS Console → DynamoDB → your table → **Backups** tab  
You should see an on-demand backup named like:
`<project>-v2-<timestamp>`

### SNS publish
- If email subscription is configured and confirmed: check your inbox
- Otherwise: SNS console metrics / CloudWatch metrics for the topic

### CloudWatch Logs (recommended proof)

(Adjust if your Lambda function name differs. The log group is typically `/aws/lambda/<lambda_function_name>`.)

---

## Cleanup
```bash
terraform destroy
```
