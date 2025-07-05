resource "aws_sqs_queue" "trade_queue" {
  name                      = "${var.project_name}-${var.env}-trade-queue.fifo"
  delay_seconds             = 0
  fifo_queue                = true
  max_message_size          = 262144 # 256 KB (기본값)
  message_retention_seconds = 345600 # 4일
}

resource "aws_ssm_parameter" "trade_queue_url" {
  name  = "/${var.project_name}/${var.env}/finance/trade_queue_host"
  type  = "String"
  value = aws_sqs_queue.trade_queue.url
}
