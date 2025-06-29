resource "aws_ssm_parameter" "trade_queue_url" {
  name  = "/${var.project_name}/finance/trade-queue-url"
  type  = "String"
  value = aws_sqs_queue.trade_queue.url
}