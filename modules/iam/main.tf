# RDS Proxy가 사용하는 정책
# Proxy에서 DB에 접근을 하기 위해서 SSM에 저장된 DB 유저 이름과 비밀 번호를 조회한다.
# SSM은 KMS로 암호화된 데이터를 복호화한다. 따라서, Proxy는 KMS에 접근 권한도 필요하다.
resource "aws_iam_role" "rds_proxy_secret_access" {
  name               = "${var.project_name}-${var.env}-rds-proxy-role"
  assume_role_policy = data.aws_iam_policy_document.rds_proxy_assume_role.json
}

resource "aws_iam_role_policy_attachment" "secret_attach" {
  role       = aws_iam_role.rds_proxy_secret_access.name
  policy_arn = aws_iam_policy.rds_secret_access.arn
}
# API Lambda
# RDS에 접근하기 위한 권한과 ENI 생성 권한을 가진다.
# RDS에 Private Subnet을 통해 접근하기 위해선 ENI 인터페이스가 필요하므로
# ENI 생성 정책이 필요하다.
resource "aws_iam_role" "lambda_rds_connection" {
  name               = "${var.project_name}-${var.env}-api-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "api_lambda_to_save_log" {
  role       = aws_iam_role.lambda_rds_connection.name
  policy_arn = aws_iam_policy.lambda_logs.arn
}

resource "aws_iam_role_policy_attachment" "api_lambda_to_create_eni" {
  role       = aws_iam_role.lambda_rds_connection.name
  policy_arn = aws_iam_policy.create_eni.arn
}

resource "aws_iam_role_policy_attachment" "api_lambda_to_get_param" {
  role       = aws_iam_role.lambda_rds_connection.name
  policy_arn = aws_iam_policy.ssm_get_finguard_param.arn
}

resource "aws_iam_role_policy_attachment" "api_lambda_to_connect_rds_proxy" {
  role       = aws_iam_role.lambda_rds_connection.name
  policy_arn = aws_iam_policy.rds_proxy_connect.arn
}

resource "aws_iam_role_policy_attachment" "api_lambda_to_send_msg_to_trade_queue" {
  role       = aws_iam_role.lambda_rds_connection.name
  policy_arn = aws_iam_policy.sqs_send_message.arn
}
# Fraud Check Lambda가 수행할 역할
# 1. SQS로부터 큐 수신, 전송, 삭제
# 2. SQS Queue URL이 저장된 SSM을 조회
# 3. Lambda 로깅 권한
resource "aws_iam_role" "fraud_detector" {
  name               = "${var.project_name}-${var.env}-fraud-check"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "fraud_detector_to_save_log" {
  role       = aws_iam_role.fraud_detector.name
  policy_arn = aws_iam_policy.lambda_logs.arn
}

resource "aws_iam_role_policy_attachment" "fraud_detector_to_create_eni" {
  role       = aws_iam_role.fraud_detector.name
  policy_arn = aws_iam_policy.create_eni.arn
}

resource "aws_iam_role_policy_attachment" "fraud_detector_to_get_param" {
  role       = aws_iam_role.fraud_detector.name
  policy_arn = aws_iam_policy.ssm_get_finguard_param.arn
}

resource "aws_iam_role_policy_attachment" "fraud_dynamodb_alert_table" {
  role       = aws_iam_role.fraud_detector.name
  policy_arn = aws_iam_policy.dynamodb_alert_table_client.arn
}

resource "aws_iam_role_policy_attachment" "fraud_detector_to_get_msg_from_trade_queue" {
  role       = aws_iam_role.fraud_detector.name
  policy_arn = aws_iam_policy.sqs_consumer.arn
}

resource "aws_iam_role_policy_attachment" "fraud_detector_to_send_msg_to_sns" {
  role       = aws_iam_role.fraud_detector.name
  policy_arn = aws_iam_policy.sns_send.arn
}

# FCM Trigger Lambda
# DynamoDB의 Alert Table에 접근 가능한 역할
resource "aws_iam_role" "fcm_sender" {
  name               = "${var.project_name}-${var.env}-fcm-sender"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "fcm_sender_to_save_log" {
  role       = aws_iam_role.fcm_sender.name
  policy_arn = aws_iam_policy.lambda_logs.arn
}
