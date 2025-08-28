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

data "aws_iam_policy_document" "sqs_send_and_receive" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueAttributes",
      "sqs:ChangeMessageVisibility"
    ]
    resources = [var.trade_queue_arn]
  }

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


data "aws_iam_policy_document" "sqs_send_message" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueAttributes",
      "sqs:ChangeMessageVisibility"
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
      "sns:Publish",
      "sns:GetTopicAttributes"
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
  name = "finguard/test-serving"
}

data "aws_iam_policy_document" "s3_and_sagemaker" {
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


#ecsTaskExecutionRole
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}


data "aws_iam_policy_document" "xRay" {
  statement {
    sid    = "AllowXRay"
    effect = "Allow"
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets",
      "xray:GetSamplingStatisticSummaries",
    ]
    resources = ["*"]
  }
}









# ecs deploy
data "aws_iam_policy_document" "ecs_deploy_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:GoormCloud-3/finguard-msa:*"]
    }
  }
}

data "aws_iam_policy_document" "ecr_access" {
  statement {
    sid    = "ECRGeneral"
    effect = "Allow"
    actions = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPerRepo"
    effect = "Allow"
    actions = [
      "ecr:DescribeRepositories",
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:ListImages",
      "ecr:BatchDeleteImage",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:StartImageScan",
      "ecr:DescribeImageScanFindings",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
    resources = [
      "arn:aws:ecr:ap-northeast-2:381492026475:repository/account-service",
      "arn:aws:ecr:ap-northeast-2:381492026475:repository/transaction-service",
      "arn:aws:ecr:ap-northeast-2:381492026475:repository/user-service",
      "arn:aws:ecr:ap-northeast-2:381492026475:repository/sqs-service",
      "arn:aws:ecr:ap-northeast-2:381492026475:repository/fcm-service",
      "arn:aws:ecr:ap-northeast-2:381492026475:repository/xray-daemon"
    ]
  }
}

data "aws_iam_policy_document" "ecs_access" {
  statement {
    sid    = "ECSCore"
    effect = "Allow"
    actions = [
      "ecs:DescribeClusters",
      "ecs:CreateCluster",
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeTaskDefinition",
      "ecs:ListTaskDefinitions",
      "ecs:DescribeServices",
      "ecs:ListServices",
      "ecs:CreateService",
      "ecs:UpdateService",
      "ecs:TagResource",
      "ecs:UntagResource"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECSScopedCluster"
    effect = "Allow"
    actions = ["ecs:DeleteCluster"]
    resources = ["arn:aws:ecs:ap-northeast-2:381492026475:cluster/ecs-cluster"]
  }
}

data "aws_iam_policy_document" "ecs_pass_role" {
  statement {
    sid    = "ECSPassRoles"
    effect = "Allow"
    actions = ["iam:PassRole"]
    resources = [
      "arn:aws:iam::381492026475:role/ecsTaskExecutionRole",
      "arn:aws:iam::381492026475:role/ecsFCMTaskExecutionRole"
    ]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }

  statement {
    sid    = "ReadRoles"
    effect = "Allow"
    actions = ["iam:GetRole"]
    resources = [
      "arn:aws:iam::381492026475:role/ecsTaskExecutionRole",
      "arn:aws:iam::381492026475:role/*TaskRole"
    ]
  }
}

data "aws_iam_policy_document" "autoscaling" {
  statement {
    sid    = "AppAutoScaling"
    effect = "Allow"
    actions = [
      "application-autoscaling:RegisterScalableTarget",
      "application-autoscaling:DeregisterScalableTarget",
      "application-autoscaling:PutScalingPolicy",
      "application-autoscaling:DeleteScalingPolicy",
      "application-autoscaling:DescribeScalableTargets",
      "application-autoscaling:DescribeScalingPolicies",
      "application-autoscaling:DescribeScalingActivities"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowCreateSLRForAppAutoScalingECS"
    effect = "Allow"
    actions = ["iam:CreateServiceLinkedRole"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values   = ["ecs.application-autoscaling.amazonaws.com"]
    }
  }

  statement {
    sid    = "AllowGetSLR"
    effect = "Allow"
    actions = ["iam:GetRole"]
    resources = ["arn:aws:iam::381492026475:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"]
  }
}

data "aws_iam_policy_document" "network_elb" {
  statement {
    sid    = "EC2Describe"
    effect = "Allow"
    actions = [
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeNetworkInterfaces"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ELBDescribe"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:ModifyTargetGroup"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "cloudwatch_logs" {
  statement {
    sid    = "CWLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}








# ecs destroy
data "aws_iam_policy_document" "ecs_destroy_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:GoormCloud-3/finguard-msa:*"]
    }
  }
}


data "aws_iam_policy_document" "ecs_service_ops" {
  statement {
    sid    = "ECSServiceOps"
    effect = "Allow"
    actions = [
      "ecs:DescribeClusters",
      "ecs:DescribeServices",
      "ecs:ListServices",
      "ecs:UpdateService",
      "ecs:DeleteService",
      "ecs:ListTasks",
      "ecs:ListTaskDefinitions",
      "ecs:DescribeTasks",
      "ecs:ListClusters",
      "ecs:ListContainerInstances"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecs_taskdef_ops" {
  statement {
    sid    = "ECSTaskDefOps"
    effect = "Allow"
    actions = [
      "ecs:ListTaskDefinitions",
      "ecs:DeregisterTaskDefinition",
      "ecs:DescribeTaskDefinition"
    ]
    resources = ["*"]
  }
}


data "aws_iam_policy_document" "ecr_delete" {
  statement {
    sid    = "ECRDelete"
    effect = "Allow"
    actions = [
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:BatchDeleteImage",
      "ecr:DeleteRepository"
    ]
    resources = [
      "arn:aws:ecr:ap-northeast-2:381492026475:repository/account-service",
      "arn:aws:ecr:ap-northeast-2:381492026475:repository/transaction-service",
      "arn:aws:ecr:ap-northeast-2:381492026475:repository/user-service",
      "arn:aws:ecr:ap-northeast-2:381492026475:repository/sqs-service",
      "arn:aws:ecr:ap-northeast-2:381492026475:repository/fcm-service",
      "arn:aws:ecr:ap-northeast-2:381492026475:repository/xray-daemon"
    ]
  }
}

data "aws_iam_policy_document" "ecs_cluster_delete" {
  statement {
    sid    = "ECSClusterDelete"
    effect = "Allow"
    actions = ["ecs:DeleteCluster"]
    resources = ["arn:aws:ecs:ap-northeast-2:381492026475:cluster/ecs-cluster"]
  }
}

data "aws_iam_policy_document" "cloudwatch_logs_delete" {
  statement {
    sid    = "DeleteCWLogs"
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups",
      "logs:DeleteLogGroup"
    ]
    resources = ["*"]
  }
}



# aws backup policy document
data "aws_iam_policy_document" "backup_assume" {
  statement {
    effect = "Allow"
    principals { 
      type = "Service" 
      identifiers = ["backup.amazonaws.com"] 
    }
    actions = ["sts:AssumeRole"]
  }
}  