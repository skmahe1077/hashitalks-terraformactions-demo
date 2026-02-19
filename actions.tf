# Action 1: create an on-demand backup of the DynamoDB table
action "aws_dynamodb_create_backup" "on_demand" {
  config {
    table_name  = aws_dynamodb_table.demo.name
    backup_name = "${var.project}-${var.release_version}-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  }
}

# Action 2: publish a notification to SNS
action "aws_sns_publish" "notify_release" {
  config {
    topic_arn = aws_sns_topic.demo.arn
    subject   = "Terraform Actions: release workflow"
    message = jsonencode({
      project = var.project
      release = var.release_version
      table   = aws_dynamodb_table.demo.name
      note    = "Backup requested + notification published via Terraform Actions"
      time    = timestamp()
    })
  }
}

# Action 3: write a log line to CloudWatch Logs by invoking Lambda
action "aws_lambda_invoke" "write_log" {
  config {
    function_name = aws_lambda_function.ops_logger.function_name
    payload = jsonencode({
      event   = "day2_log"
      release = var.release_version
      time    = timestamp()
    })
  }
}
# Manual Action: a separate manual publish action using var.message
action "aws_sns_publish" "notify_manual" {
  config {
    topic_arn = aws_sns_topic.demo.arn
    subject   = "Terraform Actions: manual publish"
    message   = var.message
  }
}