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
  name               = "${var.project_name}-${var.env}-backend"
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

resource "aws_iam_role_policy_attachment" "api_lambda_to_write_xray" {
  role       = aws_iam_role.lambda_rds_connection.name
  policy_arn = data.aws_iam_policy.xray_write.arn
}

resource "aws_iam_role_policy_attachment" "api_lambda_to_crud_notification_table" {
  role       = aws_iam_role.lambda_rds_connection.name
  policy_arn = aws_iam_policy.notification_table_crud.arn
}
# Fraud Check Lambda가 수행할 역할
# 1. SQS로부터 큐 수신, 전송, 삭제
# 2. SQS Queue URL이 저장된 SSM을 조회
# 3. Lambda 로깅 권한
resource "aws_iam_role" "fraud_detector" {
  name               = "${var.project_name}-${var.env}-fraud-checker"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "fraud_detector_to_save_log" {
  role       = aws_iam_role.fraud_detector.name
  policy_arn = aws_iam_policy.lambda_logs.arn
}

resource "aws_iam_role_policy_attachment" "fraud_detector_to_xray" {
  role       = aws_iam_role.fraud_detector.name
  policy_arn = data.aws_iam_policy.xray_write.arn
}

resource "aws_iam_role_policy_attachment" "fraud_detector_to_create_eni" {
  role       = aws_iam_role.fraud_detector.name
  policy_arn = aws_iam_policy.create_eni.arn
}

resource "aws_iam_role_policy_attachment" "fraud_detector_to_get_param" {
  role       = aws_iam_role.fraud_detector.name
  policy_arn = aws_iam_policy.ssm_get_finguard_param.arn
}

resource "aws_iam_role_policy_attachment" "fraud_detector_to_get_tokens_from_notification_table" {
  role       = aws_iam_role.fraud_detector.name
  policy_arn = aws_iam_policy.notification_table_select.arn
}

resource "aws_iam_role_policy_attachment" "fraud_detector_to_get_msg_from_trade_queue" {
  role       = aws_iam_role.fraud_detector.name
  policy_arn = aws_iam_policy.sqs_consumer.arn
}

resource "aws_iam_role_policy_attachment" "fraud_detector_to_send_msg_to_sns" {
  role       = aws_iam_role.fraud_detector.name
  policy_arn = aws_iam_policy.sns_send.arn
}

resource "aws_iam_role_policy_attachment" "fraud_detector_to_invoe_sagemaker" {
  role       = aws_iam_role.fraud_detector.name
  policy_arn = aws_iam_policy.sagemaker_invoke_function.arn
}

# notification Trigger Lambda
resource "aws_iam_role" "notification_sender" {
  name               = "${var.project_name}-${var.env}-notification-sender"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "notification_sender_to_save_log" {
  role       = aws_iam_role.notification_sender.name
  policy_arn = aws_iam_policy.lambda_logs.arn
}

resource "aws_iam_role_policy_attachment" "notification_sender_to_write_xray" {
  role       = aws_iam_role.notification_sender.name
  policy_arn = data.aws_iam_policy.xray_write.arn
}

resource "aws_iam_role_policy_attachment" "notification_sender_to_receive_msg_from_sns" {
  role       = aws_iam_role.notification_sender.name
  policy_arn = aws_iam_policy.sns_receive.arn
}

# Sagemaker의 권한
resource "aws_iam_role" "sagemaker_execution_role" {
  name               = "${var.project_name}-${var.env}-sagemaker-execution-role"
  assume_role_policy = data.aws_iam_policy_document.sagemaker_assume_role.json
}

resource "aws_iam_role_policy_attachment" "sagemaker_attach_s3_access" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = aws_iam_policy.sagemaker_s3_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "sagemaker_attach_ecr_access" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = aws_iam_policy.sagemaker_ecr_access_policy.arn
}
