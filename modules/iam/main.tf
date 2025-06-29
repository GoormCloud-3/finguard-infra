# RDS Proxy가 사용하는 정책
# Proxy에서 DB에 접근을 하기 위해서 SSM에 저장된 DB 유저 이름과 비밀 번호를 조회한다.
# SSM은 KMS로 암호화된 데이터를 복호화한다. 따라서, Proxy는 KMS에 접근 권한도 필요하다.
data "aws_iam_policy_document" "rds_proxy_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"] # ← 핵심 포인트
    }
  }
}

data "aws_iam_policy_document" "rds_proxy_secret_access" {
  statement {
    effect  = "Allow"
    actions = ["rds-db:connect"]
    resources = [
      "arn:aws:rds-db:${var.region}:${data.aws_caller_identity.current.account_id}:dbuser:${var.rds_resource_id}/${var.db_username}"
    ]
  }

  statement {
    sid    = "SecretsManagerAccess"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [
      var.rds_proxy_secret_arn
    ]
  }

  statement {
    sid    = "KMSDecryptForSecretsAndSSM"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [
      data.aws_kms_key.secretsmanager.arn,
      data.aws_kms_key.ssm.arn
    ]
  }
}

resource "aws_iam_role" "rds_proxy_secret_access" {
  name               = "${var.project_name}-${var.env}-rds-proxy-role"
  assume_role_policy = data.aws_iam_policy_document.rds_proxy_assume_role.json
}

resource "aws_iam_policy" "rds_secret_access" {
  name   = "${var.project_name}-${var.env}-secret-access"
  policy = data.aws_iam_policy_document.rds_proxy_secret_access.json
}

resource "aws_iam_role_policy_attachment" "secret_attach" {
  role       = aws_iam_role.rds_proxy_secret_access.name
  policy_arn = aws_iam_policy.rds_secret_access.arn
}

# Lambda
# RDS에 접근하기 위한 권한과 ENI 생성 권한을 가진다.
# RDS에 Private Subnet을 통해 접근하기 위해선 ENI 인터페이스가 필요하므로
# ENI 생성 정책이 필요하다.
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

data "aws_iam_policy_document" "rds_proxy_connect" {
  statement {
    effect  = "Allow"
    actions = ["rds-db:connect"]
    resources = [
      "arn:aws:rds-db:${var.region}:${data.aws_caller_identity.current.account_id}:dbuser:${var.rds_resource_id}/${var.db_username}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
    resources = [
      "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/finguard/finance/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "lambda_rds_connection" {
  name               = "${var.project_name}-${var.env}-lambda-rds-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_policy" "rds_proxy_connect" {
  name   = "${var.project_name}-${var.env}-rds-proxy-connect-policy"
  policy = data.aws_iam_policy_document.rds_proxy_connect.json
}

resource "aws_iam_role_policy_attachment" "connect_attach" {
  role       = aws_iam_role.lambda_rds_connection.name
  policy_arn = aws_iam_policy.rds_proxy_connect.arn
}

# Alert Lambda가 수행할 역할
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
    resources = [var.trade_queue_arn]
  }
}

resource "aws_iam_policy" "sqs_access" {
  name   = "${var.project_name}-${var.env}-sqs-access"
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
      var.trade_queue_url_ssm_arn
    ]
  }
}

resource "aws_iam_policy" "ssm_access" {
  name   = "${var.project_name}-${var.env}-sqs-get-policy"
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
  name   = "${var.project_name}-${var.env}-lambda-log-policy"
  policy = data.aws_iam_policy_document.lambda_logs.json
}

resource "aws_iam_role" "fraud_detector" {
  name               = "${var.project_name}-${var.env}-fraud-detector-role"
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

resource "aws_iam_role_policy_attachment" "attach_log_access" {
  role       = aws_iam_role.fraud_detector.name
  policy_arn = aws_iam_policy.lambda_logs.arn
}

# FCM Trigger Lambda
# DynamoDB의 Alert Table에 접근 가능한 역할
data "aws_iam_policy_document" "dynamodb_alert_table_client" {
  statement {
    sid    = "DynamoDBTableAccess"
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:Query"
    ]

    resources = [
      var.alert_table_arn
    ]
  }
}

resource "aws_iam_policy" "dynamodb_alert_table_client" {
  name   = "${var.project_name}-${var.env}-dynamodb_alert_table_client"
  policy = data.aws_iam_policy_document.dynamodb_alert_table_client.json
}

resource "aws_iam_role" "fcm_trigger" {
  name               = "${var.project_name}-${var.env}-fcm-trigger"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "attach_log_access_to_fcm_trigger" {
  role       = aws_iam_role.fcm_trigger.name
  policy_arn = aws_iam_policy.lambda_logs.arn
}

resource "aws_iam_role_policy_attachment" "attach_alert_table_access_to_fcm_trigger" {
  role       = aws_iam_role.fcm_trigger.name
  policy_arn = aws_iam_policy.dynamodb_alert_table_client.arn
}

# elasticache 접근 허용을 위한 정책
data "aws_iam_policy_document" "elasticache_access" {
  statement {
    effect = "Allow"

    actions = [
      "elasticache:DescribeCacheClusters",
      "elasticache:ListTagsForResource"
    ]

    resources = [
      "arn:aws:elasticache:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.elasticache_cluster_id}"
    ]
  }
}

resource "aws_iam_policy" "elasticache" {
  name        = "${var.project_name}-${var.env}-elasticache-client"
  description = "Allows describing specific ElastiCache cluster"

  policy = data.aws_iam_policy_document.elasticache_access.json
}

resource "aws_iam_role_policy_attachment" "elasticache" {
  role       = aws_iam_role.lambda_rds_connection.name
  policy_arn = aws_iam_policy.elasticache.arn
}
