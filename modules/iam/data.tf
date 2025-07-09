data "aws_caller_identity" "current" {}

# AWS에서 SecretsManager가 사용하는 기본 Key
data "aws_kms_key" "secretsmanager" {
  key_id = "alias/aws/secretsmanager"
}

# AWS에서 SSM Parameter Store가 사용하는 기본 Key
data "aws_kms_key" "ssm" {
  key_id = "alias/aws/ssm"
}

# RDS Proxy
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

# Lambda 공통 정책
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

data "aws_iam_policy_document" "create_eni" {
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

# API Lambda
data "aws_iam_policy_document" "rds_proxy_connect" {
  statement {
    effect = "Allow"
    actions = [
      "rds-db:connect",
      "rds:DescribeDBProxies",
      "rds:DescribeDBProxyTargetGroups",
      "rds:DescribeDBProxyTargets"
    ]
    resources = [
      # "arn:aws:rds-db:${var.region}:${data.aws_caller_identity.current.account_id}:dbuser:${var.rds_proxy_resource_id}/${var.db_username}"
      "arn:aws:rds-db:${var.region}:${data.aws_caller_identity.current.account_id}:dbuser:*/${var.db_username}"
    ]
  }
}

data "aws_iam_policy_document" "sqs_send_message" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [var.trade_queue_arn]
  }
}

# Fraud Check Lambda
data "aws_iam_policy_document" "sqs_consumer" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [var.trade_queue_arn]
  }
}

data "aws_iam_policy_document" "ssm_get_finguard_param" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
    resources = [
      "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/finguard/*"
    ]
  }
}

# Lambda log
data "aws_iam_policy" "xray_write" {
  name = "AWSXRayDaemonWriteAccess"
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

# DynamoDB Alert Table CRUD
data "aws_iam_policy_document" "notification_table_crud" {
  statement {
    sid    = "DynamoDBTableAccess"
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:Query",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:DescribeTable"
    ]

    resources = [
      var.alert_table_arn
    ]
  }
}

# fraud-detector가 사용할 정책 
# 단순 조회만 가능
data "aws_iam_policy_document" "notification_table_select" {
  statement {
    sid    = "DynamoDBTableAccess"
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:DescribeTable"
    ]

    resources = [
      var.alert_table_arn
    ]
  }
}

# SNS
data "aws_iam_policy_document" "sns_send" {
  statement {
    effect = "Allow"

    actions = [
      "sns:Publish"
    ]

    resources = [
      "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:${var.sns_topic_name}"
    ]
  }
}

data "aws_iam_policy_document" "sns_receive" {
  statement {
    effect = "Allow"

    actions = [
      "sns:Subscribe",
      "sns:Receive",
      "sns:ListSubscriptionsByTopic"
    ]

    resources = [
      "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:${var.sns_topic_name}"
    ]
  }
}

# Sagemaker S3 접근 권한
data "aws_iam_policy_document" "sagemaker_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "sagemaker_s3_access" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]

    resources = [
      var.ml_bucket_arn,
      "${var.ml_bucket_arn}/*"
    ]
  }
}

data "aws_ecr_repository" "fraud_check" {
  name = "finguard/fraud-check-ml"
}

data "aws_iam_policy_document" "sagemaker_ecr_access_policy" {
  statement {
    sid    = "ECRPullAccess"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECRImageAccess"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]

    resources = [data.aws_ecr_repository.fraud_check.arn]
  }
}

data "aws_iam_policy_document" "sagemaker_invoke_endpoint_policy" {
  statement {
    sid    = "InvokeSageMakerEndpoint"
    effect = "Allow"

    actions = [
      "sagemaker:InvokeEndpoint"
    ]

    resources = [
      "arn:aws:sagemaker:${var.region}:${data.aws_caller_identity.current.account_id}:endpoint/${var.sagemaker_endpoint_name}"
    ]
  }
}

