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



# ecsTaskExecutionRole
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_to_create_eni" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = aws_iam_policy.create_eni.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_to_lambda_logs" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = aws_iam_policy.lambda_logs.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_to_notification_table_crud" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = aws_iam_policy.notification_table_crud.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_to_rds_proxy_connect" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = aws_iam_policy.rds_proxy_connect.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_to_s3_and_sagemaker" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = aws_iam_policy.s3_and_sagemaker.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_to_sns_send" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = aws_iam_policy.sns_send.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_to_ssm_get_finguard_param" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = aws_iam_policy.ssm_get_finguard_param.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_to_xRay" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = aws_iam_policy.xRay.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_to_sqs_send_and_receive" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = aws_iam_policy.sqs_send_and_receive.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_to_amazon_ec2_container_registry_read_only" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


# 역할 추가: 콘솔 인라인 정책에서 '특정 리소스'에 필요한 최소치만 보강
#  - CloudWatch Logs: /ecs/finguard-fcm-task 로그 그룹 쓰기
#  - SSM: prod/firebase-service-account-json 파라미터 읽기


data "aws_iam_policy_document" "ecs_task_inline_logs_and_ssm" {
  statement {
    sid     = "LogsWriteFcmTask"
    effect  = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:ap-northeast-2:381492026475:log-group:/ecs/finguard-fcm-task",
      "arn:aws:logs:ap-northeast-2:381492026475:log-group:/ecs/finguard-fcm-task:*",
    ]
  }

  statement {
    sid     = "SsmGetFirebaseParam"
    effect  = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]

    resources = [
      "arn:aws:ssm:ap-northeast-2:381492026475:parameter/prod/firebase-service-account-json",
    ]
  }
}

resource "aws_iam_role_policy" "ecs_task_inline_logs_and_ssm" {
  name   = "ecsTaskExecutionRole-inline-logs-and-ssm"
  role   = aws_iam_role.ecsTaskExecutionRole.id
  policy = data.aws_iam_policy_document.ecs_task_inline_logs_and_ssm.json
}




#ecsDeployRole
resource "aws_iam_role" "ecs_deploy_role" {
  name               = "ecs-deploy-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_deploy_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecsDeploy_to_ecr_access" {
  role       = aws_iam_role.ecs_deploy_role.name
  policy_arn = aws_iam_policy.ecr_access.arn
}

resource "aws_iam_role_policy_attachment" "ecsDeploy_to_ecs_access" {
  role       = aws_iam_role.ecs_deploy_role.name
  policy_arn = aws_iam_policy.ecs_access.arn
}

resource "aws_iam_role_policy_attachment" "ecsDeploy_to_ecs_pass_role" {
  role       = aws_iam_role.ecs_deploy_role.name
  policy_arn = aws_iam_policy.ecs_pass_role.arn
}

resource "aws_iam_role_policy_attachment" "ecsDeploy_to_autoscaling" {
  role       = aws_iam_role.ecs_deploy_role.name
  policy_arn = aws_iam_policy.autoscaling.arn
}

resource "aws_iam_role_policy_attachment" "ecsDeploy_to_network_elb" {
  role       = aws_iam_role.ecs_deploy_role.name
  policy_arn = aws_iam_policy.network_elb.arn
}

resource "aws_iam_role_policy_attachment" "ecsDeploy_to_cloudwatch_logs" {
  role       = aws_iam_role.ecs_deploy_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs.arn
}


#ecsDestroyRole
resource "aws_iam_role" "ecs_destroy_role" {
  name               = "ecs-destroy-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_destroy_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecsDeploy_to_ecs_service_ops" {
  role       = aws_iam_role.ecs_destroy_role.name
  policy_arn = aws_iam_policy.ecs_service_ops.arn
}

resource "aws_iam_role_policy_attachment" "ecsDeploy_to_ecs_taskdef_ops" {
  role       = aws_iam_role.ecs_destroy_role.name
  policy_arn = aws_iam_policy.ecs_taskdef_ops.arn
}

resource "aws_iam_role_policy_attachment" "ecsDeploy_to_ecr_delete" {
  role       = aws_iam_role.ecs_destroy_role.name
  policy_arn = aws_iam_policy.ecr_delete.arn
}

resource "aws_iam_role_policy_attachment" "ecsDeploy_to_ecs_cluster_delete" {
  role       = aws_iam_role.ecs_destroy_role.name
  policy_arn = aws_iam_policy.ecs_cluster_delete.arn
}

resource "aws_iam_role_policy_attachment" "ecsDeploy_to_cloudwatch_logs_delete" {
  role       = aws_iam_role.ecs_destroy_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_delete.arn
}


# aws backup role
resource "aws_iam_role" "backup" {
  name               = "${var.project_name}-${var.env}-backup-role"
  assume_role_policy = data.aws_iam_policy_document.backup_assume.json
}
# 관리형 정책 2개 부착(백업/복구에 필요)
resource "aws_iam_role_policy_attachment" "backup_role_attach_backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}
resource "aws_iam_role_policy_attachment" "backup_role_attach_restore" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}