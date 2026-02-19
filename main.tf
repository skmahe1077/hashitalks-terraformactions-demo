provider "aws" {
  region = var.region
}
resource "aws_dynamodb_table" "demo" {
  name         = "${var.project}-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Project = var.project
    Demo    = "TerraformActions"
  }
}

resource "aws_sns_topic" "demo" {
  name = "${var.project}-topic"

  tags = {
    Project = var.project
    Demo    = "TerraformActions"
  }
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.email == "" ? 0 : 1
  topic_arn = aws_sns_topic.demo.arn
  protocol  = "email"
  endpoint  = var.email
}

data "archive_file" "logger_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_logger"
  output_path = "${path.module}/lambda_logger.zip"
}

resource "aws_iam_role" "logger_exec" {
  name = "${var.project}-logger-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "logger_basic_logs" {
  role       = aws_iam_role.logger_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "ops_logger" {
  function_name = "${var.project}-function"
  role          = aws_iam_role.logger_exec.arn
  handler       = "handler.handler"
  runtime       = "python3.12"

  filename         = data.archive_file.logger_zip.output_path
  source_code_hash = data.archive_file.logger_zip.output_base64sha256

  environment {
    variables = {
      PROJECT = var.project
    }
  }
}

# Update release_version to trigger Actions automatically.
resource "aws_ssm_parameter" "release" {
  name  = "/${var.project}/release_version"
  type  = "String"
  value = var.release_version

  tags = {
    Project = var.project
    Demo    = "TerraformActions"
  }

  lifecycle {
    action_trigger {
      events    = [after_create, after_update]
      condition = var.enable_release_workflow
      actions = [
        action.aws_dynamodb_create_backup.on_demand,
        action.aws_sns_publish.notify_release,
        action.aws_lambda_invoke.write_log
      ]
    }
  }
}
