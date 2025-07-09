resource "aws_iam_policy" "rds_secret_access" {
  name   = "${var.project_name}-${var.env}-secret-access"
  policy = data.aws_iam_policy_document.rds_proxy_secret_access.json
}

resource "aws_iam_policy" "rds_proxy_connect" {
  name   = "${var.project_name}-${var.env}-rds-proxy-connect-policy"
  policy = data.aws_iam_policy_document.rds_proxy_connect.json
}

# Lambda 공통 정책
# Private Subnet에 람다 만드려면
# ENI 정책은 공통으로 필요함.
resource "aws_iam_policy" "create_eni" {
  name   = "${var.project_name}-${var.env}-create-eni"
  policy = data.aws_iam_policy_document.create_eni.json
}

resource "aws_iam_policy" "lambda_logs" {
  name   = "${var.project_name}-${var.env}-lambda-log-policy"
  policy = data.aws_iam_policy_document.lambda_logs.json
}

resource "aws_iam_policy" "ssm_get_finguard_param" {
  name   = "${var.project_name}-${var.env}-ssm-get-param"
  policy = data.aws_iam_policy_document.ssm_get_finguard_param.json
}

resource "aws_iam_policy" "sqs_send_message" {
  name   = "${var.project_name}-${var.env}-trade-queue-send-msg-policy"
  policy = data.aws_iam_policy_document.sqs_send_message.json
}

resource "aws_iam_policy" "sqs_consumer" {
  name   = "${var.project_name}-${var.env}-sqs-consumer"
  policy = data.aws_iam_policy_document.sqs_consumer.json
}

resource "aws_iam_policy" "notification_table_crud" {
  name   = "${var.project_name}-${var.env}-dynamodb-notification-table-crud"
  policy = data.aws_iam_policy_document.notification_table_crud.json
}

resource "aws_iam_policy" "notification_table_select" {
  name   = "${var.project_name}-${var.env}-dynamodb-notification-table-select"
  policy = data.aws_iam_policy_document.notification_table_select.json
}

resource "aws_iam_policy" "sns_send" {
  name   = "${var.project_name}-${var.env}-sns-send"
  policy = data.aws_iam_policy_document.sns_send.json
}

resource "aws_iam_policy" "sns_receive" {
  name   = "${var.project_name}-${var.env}-sns-receive"
  policy = data.aws_iam_policy_document.sns_receive.json
}

resource "aws_iam_policy" "sagemaker_s3_access_policy" {
  name   = "${var.project_name}-${var.env}-sagemaker-s3-access"
  policy = data.aws_iam_policy_document.sagemaker_s3_access.json
}

resource "aws_iam_policy" "sagemaker_ecr_access_policy" {
  name   = "${var.project_name}-${var.env}-sagemaker-ecr-fraud-image-access"
  policy = data.aws_iam_policy_document.sagemaker_ecr_access_policy.json
}

resource "aws_iam_policy" "sagemaker_invoke_function" {
  name   = "${var.project_name}-${var.env}-sagemaker-invoke-function"
  policy = data.aws_iam_policy_document.sagemaker_invoke_endpoint_policy.json
}
