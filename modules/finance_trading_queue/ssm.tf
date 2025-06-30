resource "aws_ssm_parameter" "trade_queue_url" {
  name  = "/${var.project_name}/${var.env}/finance/trade_queue_host"
  type  = "String"
  value = aws_sqs_queue.trade_queue.url
}
