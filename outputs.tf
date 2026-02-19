output "topic_arn" {
  value = aws_sns_topic.demo.arn
}

output "logger_lambda_name" {
  value = aws_lambda_function.ops_logger.function_name
}

