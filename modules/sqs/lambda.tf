resource "aws_lambda_function" "fraud_detector" {
  function_name = "${var.project_name}-fraud-detector"
  role          = aws_iam_role.fraud_detector.arn
  handler       = "handler.handler" # handler.py의 handler 함수
  runtime       = "python3.11"      # 또는 3.9 / 3.10도 가능

  filename         = "${path.module}/lambda.zip" # Python 코드 압축본
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")

  timeout = 30
}