resource "aws_sqs_queue" "trade_queue" {
  name                      = "${var.project_name}-${var.env}-trade-queue"
  delay_seconds             = 0
  max_message_size          = 262144 # 256 KB (기본값)
  message_retention_seconds = 345600 # 4일
}

# Lambda function needs to be created before enabling this
# resource "aws_lambda_event_source_mapping" "sqs_trigger" {
#   event_source_arn = aws_sqs_queue.trade_queue.arn
#   function_name    = aws_lambda_function.fraud_detector.arn
#   batch_size       = 10
#   enabled          = true
# }