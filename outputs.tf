output "table_name" {
  value = aws_dynamodb_table.demo.name
}

output "topic_arn" {
  value = aws_sns_topic.demo.arn
}

output "logger_lambda_name" {
  value = aws_lambda_function.ops_logger.function_name
}

output "logger_log_group" {
  value = aws_cloudwatch_log_group.logger.name
}
