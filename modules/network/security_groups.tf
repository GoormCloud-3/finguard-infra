// 보안그룹 여러개 적용해야 할 시 사용할 부분
locals {
  cw_logs_allowed_sgs = {
    backend      = aws_security_group.backend.id
    ecs_b_worker = aws_security_group.ecs_b_worker.id
  }
}


resource "aws_security_group" "allow_all" {
  name        = "${var.project_name}-${var.env}-public"
  description = "Allow all inbound and outbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS가 사용할 보안 그룹
resource "aws_security_group" "rds" {
  name   = "${var.project_name}-${var.env}-rds"
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_proxy" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.rds_proxy.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_public" {
  count = var.env == "dev" ? 1 : 0

  security_group_id = aws_security_group.rds.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3306
  to_port           = 3306
  ip_protocol       = "tcp"
}

resource "aws_security_group" "rds_proxy" {
  name   = "${var.project_name}-${var.env}-rds-proxy"
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "rds_proxy_from_backend" {
  security_group_id            = aws_security_group.rds_proxy.id
  referenced_security_group_id = aws_security_group.backend.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "rds_proxy_to_rds" {
  security_group_id            = aws_security_group.rds_proxy.id
  referenced_security_group_id = aws_security_group.rds.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

# backend
resource "aws_security_group" "backend" {
  name   = "${var.project_name}-${var.env}-backend"
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_security_group_egress_rule" "backend_to_rds_proxy" {
  security_group_id            = aws_security_group.backend.id
  referenced_security_group_id = aws_security_group.rds_proxy.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "backend_to_elasticache" {
  security_group_id            = aws_security_group.backend.id
  referenced_security_group_id = aws_security_group.elasticache.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "backend_to_endpoints" {
  security_group_id            = aws_security_group.backend.id
  referenced_security_group_id = aws_security_group.ssm_vpc_endpoint.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "backend_to_dynamodb_endpoint" {
  security_group_id = aws_security_group.backend.id
  prefix_list_id    = data.aws_prefix_list.dynamodb.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "backend_to_s3_endpoint" {
  security_group_id = aws_security_group.backend.id
  prefix_list_id    = data.aws_prefix_list.s3.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

}

resource "aws_vpc_security_group_egress_rule" "backend_to_sqs_endpoint" {
  security_group_id            = aws_security_group.backend.id
  referenced_security_group_id = aws_security_group.sqs_vpc_endpoint.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "backend_to_sns_endpoint" {
  security_group_id            = aws_security_group.backend.id
  referenced_security_group_id = aws_security_group.sns_vpc_endpoint.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "backend_to_ecr_api_endpoint" {
  security_group_id            = aws_security_group.backend.id
  referenced_security_group_id = aws_security_group.ecr_api_endpoint.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "backend_to_ecr_dkr_endpoint" {
  security_group_id            = aws_security_group.backend.id
  referenced_security_group_id = aws_security_group.ecr_dkr_endpoint.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "backend_to_cloudwatch_logs_endpoint" {
  security_group_id            = aws_security_group.backend.id
  referenced_security_group_id = aws_security_group.cloudwatch_logs_endpoint.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "backend_to_sagemaker_runtime_endpoint" {
  security_group_id            = aws_security_group.backend.id
  referenced_security_group_id = aws_security_group.sagemaker_runtime_endpoint.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "backend_to_xray_endpoint" {
  security_group_id            = aws_security_group.backend.id
  referenced_security_group_id = aws_security_group.xray_endpoint.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}


resource "aws_security_group" "ecr_api_endpoint" {
  name   = "${var.project_name}-${var.env}-ecr-api-endpoint"
  vpc_id = aws_vpc.main.id
}
resource "aws_vpc_security_group_ingress_rule" "ecr_api_endpoint_from_backend" {
  security_group_id            = aws_security_group.ecr_api_endpoint.id
  referenced_security_group_id = aws_security_group.backend.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}


resource "aws_security_group" "ecr_dkr_endpoint" {
  name   = "${var.project_name}-${var.env}-ecr-dkr-endpoint"
  vpc_id = aws_vpc.main.id
}
resource "aws_vpc_security_group_ingress_rule" "ecr_dkr_endpoint_from_backend" {
  security_group_id            = aws_security_group.ecr_dkr_endpoint.id
  referenced_security_group_id = aws_security_group.backend.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}


// ecr api/dkr에 추가로 적용할 보안그룹

resource "aws_security_group" "vpce_common" {
  name   = "${var.project_name}-${var.env}-vpce-sg"
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-${var.env}-vpce-sg" }
// 아웃바운드 규칙 추가
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// ecr api/dkr에 추가로 적용할 보안그룹의 인바운드 규칙

# new-vpce-sg 인바운드 443: backend → VPCE
resource "aws_vpc_security_group_ingress_rule" "vpce_from_backend" {
  security_group_id            = aws_security_group.vpce_common.id
  referenced_security_group_id = aws_security_group.backend.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = "Allow 443 from backend to VPCE"
}

# new-vpce-sg 인바운드 443: ECS 워커 → VPCE
resource "aws_vpc_security_group_ingress_rule" "vpce_from_ecs_worker" {
  security_group_id            = aws_security_group.vpce_common.id
  referenced_security_group_id = aws_security_group.ecs_b_worker.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = "Allow 443 from ECS worker to VPCE"
}

// ecs worker용 보안그룹 추가

resource "aws_security_group" "ecs_b_worker" {
  name        = "${var.project_name}-${var.env}-ecs-b-worker-sg"
  description = "ECS B worker tasks (egress 443 only)"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-${var.env}-ecs-b-worker-sg" }
}


resource "aws_security_group" "cloudwatch_logs_endpoint" {
  name   = "${var.project_name}-${var.env}-cloudwatch-logs-endpoint"
  vpc_id = aws_vpc.main.id
}
resource "aws_vpc_security_group_ingress_rule" "cloudwatch_logs_endpoint_from_backend" {
  for_each                     = local.cw_logs_allowed_sgs
  security_group_id            = aws_security_group.cloudwatch_logs_endpoint.id
  referenced_security_group_id = each.value // 인바운드 보안그룹 추가
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}


resource "aws_security_group" "sagemaker_runtime_endpoint" {
  name   = "${var.project_name}-${var.env}-sagemaker-runtime-endpoint"
  vpc_id = aws_vpc.main.id
}
resource "aws_vpc_security_group_ingress_rule" "sagemaker_runtime_endpoint_from_backend" {
  security_group_id            = aws_security_group.sagemaker_runtime_endpoint.id
  referenced_security_group_id = aws_security_group.backend.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}


resource "aws_security_group" "xray_endpoint" {
  name   = "${var.project_name}-${var.env}-xray-endpoint"
  vpc_id = aws_vpc.main.id
}
resource "aws_vpc_security_group_ingress_rule" "xray_endpoint_from_backend" {
  security_group_id            = aws_security_group.xray_endpoint.id
  referenced_security_group_id = aws_security_group.backend.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "backend_from_alb" {
  security_group_id            = aws_security_group.backend.id
  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = 8000
  to_port                      = 8000
  ip_protocol                  = "tcp"
}

resource "aws_security_group" "alb_sg" {
  name   = "${var.project_name}-${var.env}-alb-sg"
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "alb_from_anywhere" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0" #  CIDR로 지정
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_backend" {
  security_group_id            = aws_security_group.alb_sg.id
  referenced_security_group_id = aws_security_group.backend.id
  from_port                    = 8000
  to_port                      = 8000
  ip_protocol                  = "tcp"
}




# sns
resource "aws_security_group" "sns_vpc_endpoint" {
  name   = "${var.project_name}-${var.env}-sns-vpc-endpoint"
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "sns_endpoint_from_fraud_checker" {
  security_group_id            = aws_security_group.sns_vpc_endpoint.id
  referenced_security_group_id = aws_security_group.fraud_checker.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "sns_endpoint_from_backend" {
  security_group_id            = aws_security_group.sns_vpc_endpoint.id
  referenced_security_group_id = aws_security_group.backend.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}


#ssm
resource "aws_security_group" "ssm_vpc_endpoint" {
  name   = "${var.project_name}-${var.env}-ssm-vpc-endpoint"
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "ssm_endpoint_from_backend" {
  for_each                     = local.cw_logs_allowed_sgs
  security_group_id            = aws_security_group.ssm_vpc_endpoint.id
  referenced_security_group_id = each.value
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ssm_endpoint_from_fraud_checker" {
  security_group_id            = aws_security_group.ssm_vpc_endpoint.id
  referenced_security_group_id = aws_security_group.fraud_checker.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_security_group" "kms_vpc_endpoint" {
  name        = "${var.project_name}-${var.env}-kms-vpc-endpoint"
  description = "Allow backend to access kms via VPC endpoint"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "kms_endpoint_from_backend" {
  security_group_id            = aws_security_group.kms_vpc_endpoint.id
  referenced_security_group_id = aws_security_group.backend.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_security_group" "ecr_vpc_endpoint" {
  name   = "${var.project_name}-${var.env}-ecr-vpc-endpoint"
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "ecr_endpoint_from_ml" {
  security_group_id            = aws_security_group.ecr_vpc_endpoint.id
  referenced_security_group_id = aws_security_group.ml_server.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_security_group" "elasticache" {
  name   = "${var.project_name}-${var.env}-elasticache"
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "elasticache_from_backend" {
  security_group_id            = aws_security_group.elasticache.id
  referenced_security_group_id = aws_security_group.backend.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
}

resource "aws_security_group" "sqs_vpc_endpoint" {
  name   = "${var.project_name}-${var.env}-sqs-vpc-endpoint"
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "sqs_endpoint_from_backend" {
  security_group_id            = aws_security_group.sqs_vpc_endpoint.id
  referenced_security_group_id = aws_security_group.backend.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_security_group" "fraud_checker" {
  name   = "${var.project_name}-${var.env}-fraud-checker"
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_security_group_egress_rule" "fraud_checker_to_dynamodb_endpoint" {
  security_group_id = aws_security_group.fraud_checker.id
  prefix_list_id    = data.aws_prefix_list.dynamodb.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "fraud_checker_to_ssm_endpoint" {
  security_group_id            = aws_security_group.fraud_checker.id
  referenced_security_group_id = aws_security_group.ssm_vpc_endpoint.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "fraud_checker_to_sns_endpoint" {
  security_group_id            = aws_security_group.fraud_checker.id
  referenced_security_group_id = aws_security_group.sns_vpc_endpoint.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "fraud_checker_to_ecr_endpoint" {
  security_group_id            = aws_security_group.fraud_checker.id
  referenced_security_group_id = aws_security_group.ecr_vpc_endpoint.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}




# Sagemaker가 서버리스 엔드포인트를 사용하게 되면서 
# 필요 없어짐.(서버리스 엔드포인트가 VPC 구성을 지원 안함)
resource "aws_security_group" "ml_server" {
  name   = "${var.project_name}-${var.env}-ml-server"
  vpc_id = aws_vpc.main.id
}



