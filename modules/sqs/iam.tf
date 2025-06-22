# Lambda가 수행할 역할
# 1. SQS로부터 큐 수신, 전송, 삭제
# 2. SQS Queue URL이 저장된 SSM을 조회
# 3. Lambda 로깅 권한
data "aws_iam_policy_document" "sqs_access" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [aws_sqs_queue.trade_queue.arn]
  }
}

resource "aws_iam_policy" "sqs_access" {
  name   = "MySqsAccessPolicy"
  policy = data.aws_iam_policy_document.sqs_access.json
}

data "aws_iam_policy_document" "ssm_access" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
    resources = [
      aws_ssm_parameter.trade_queue_url.arn
    ]
  }
}

resource "aws_iam_policy" "ssm_access" {
  name   = "${var.project_name}-sqs-get-policy"
  policy = data.aws_iam_policy_document.ssm_access.json
}

data "aws_iam_policy_document" "lambda_logs" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda_logs" {
  name   = "${var.project_name}-lambda-log-policy"
  policy = data.aws_iam_policy_document.lambda_logs.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "fraud_detector" {
  name               = "${var.project_name}-fraud-detector-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "attach_sqs_access" {
  role       = aws_iam_role.fraud_detector.name
  policy_arn = aws_iam_policy.sqs_access.arn
}

resource "aws_iam_role_policy_attachment" "attach_ssm_access" {
  role       = aws_iam_role.fraud_detector.name
  policy_arn = aws_iam_policy.ssm_access.arn
}

resource "aws_iam_role_policy_attachment" "attach_ssm_access" {
  role       = aws_iam_role.fraud_detector.name
  policy_arn = aws_iam_policy.lambda_logs.arn
}
