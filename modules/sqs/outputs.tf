output "trade_queue_arn" {
  value       = aws_sqs_queue.trade_queue.arn
  sensitive   = true
  description = "Queue의 ARN"
}

output "trade_queue_url_ssm_arn" {
  value       = aws_ssm_parameter.trade_queue_url.arn
  sensitive   = true
  description = "SSM Parameter Store의 Trade Queue URL의 ARN"
}
