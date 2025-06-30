resource "aws_sqs_queue" "trade_queue" {
  name                      = "${var.project_name}-${var.env}-trade-queue"
  delay_seconds             = 0
  max_message_size          = 262144 # 256 KB (기본값)
  message_retention_seconds = 345600 # 4일
}
