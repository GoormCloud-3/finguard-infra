output "table_arn" {
  value       = aws_dynamodb_table.notification.arn
  description = "Table의 ARN"
}
