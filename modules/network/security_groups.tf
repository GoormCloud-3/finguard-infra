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

resource "aws_security_group" "rds" {
  name   = "${var.project_name}-${var.env}-rds"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "rds_proxy" {
  name   = "${var.project_name}-${var.env}-rds-proxy"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "backend" {
  name   = "${var.project_name}-${var.env}-backend"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "ssm_vpc_endpoint" {
  name   = "${var.project_name}-${var.env}-ssm-vpc-endpoint"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "kms_vpc_endpoint" {
  name        = "${var.project_name}-${var.env}-kms-vpc-endpoint"
  description = "Allow Lambda to access kms via VPC endpoint"
  vpc_id      = aws_vpc.main.id
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

resource "aws_security_group" "sqs_vpc_endpoint" {
  name   = "${var.project_name}-${var.env}-sqs-vpc-endpoint"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "fraud_checker" {
  name   = "${var.project_name}-${var.env}-fraud-checker"
  vpc_id = aws_vpc.main.id
}

# Inbount 
# fraud-checker로부터 443 접근 허용해야함.

# Outbount
# ml server(sagemaker)는 S3 연결(게이트웨이라서 엔드포인트 추가하고 라우트 테이블 추가하면 됨)
# ECR VPC Endpoint에 접근 가능해야함.

resource "aws_security_group" "ml_server" {
  name   = "${var.project_name}-${var.env}-ml-server"
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "ml_server_from_fraud_checker" {
  security_group_id            = aws_security_group.ml_server.id
  referenced_security_group_id = aws_security_group.fraud_checker.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ml_server_to_ecr_vpc_endpoint" {
  security_group_id            = aws_security_group.ml_server.id
  referenced_security_group_id = aws_security_group.ecr_vpc_endpoint.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_security_group" "dynamodb_vpc_endpoint" {
  name   = "${var.project_name}-${var.env}-dynamodb-vpc-endpoint"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "sns_vpc_endpoint" {
  name   = "${var.project_name}-${var.env}-sns-vpc-endpoint"
  vpc_id = aws_vpc.main.id
}

# === Ingress Rules ===
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

resource "aws_vpc_security_group_ingress_rule" "rds_proxy_from_backend" {
  security_group_id            = aws_security_group.rds_proxy.id
  referenced_security_group_id = aws_security_group.backend.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "elasticache_from_lambda" {
  security_group_id            = aws_security_group.elasticache.id
  referenced_security_group_id = aws_security_group.backend.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ssm_endpoint_from_lambda" {
  security_group_id            = aws_security_group.ssm_vpc_endpoint.id
  referenced_security_group_id = aws_security_group.backend.id
  from_port                    = 443
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

resource "aws_vpc_security_group_ingress_rule" "kms_endpoint_from_lambda" {
  security_group_id            = aws_security_group.kms_vpc_endpoint.id
  referenced_security_group_id = aws_security_group.backend.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "sqs_endpoint_from_lambda" {
  security_group_id            = aws_security_group.sqs_vpc_endpoint.id
  referenced_security_group_id = aws_security_group.backend.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "dynamodb_endpoint_from_fraud_checker" {
  security_group_id            = aws_security_group.dynamodb_vpc_endpoint.id
  referenced_security_group_id = aws_security_group.fraud_checker.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "sns_endpoint_from_fraud_checker" {
  security_group_id            = aws_security_group.sns_vpc_endpoint.id
  referenced_security_group_id = aws_security_group.fraud_checker.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

# === Egress Rules ===
resource "aws_vpc_security_group_egress_rule" "lambda_to_rds_proxy" {
  security_group_id            = aws_security_group.backend.id
  referenced_security_group_id = aws_security_group.rds_proxy.id
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

resource "aws_vpc_security_group_egress_rule" "lambda_to_elasticache" {
  security_group_id            = aws_security_group.backend.id
  referenced_security_group_id = aws_security_group.elasticache.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "lambda_to_endpoints" {
  security_group_id            = aws_security_group.backend.id
  referenced_security_group_id = aws_security_group.ssm_vpc_endpoint.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "fraud_checker_to_endpoints" {
  security_group_id            = aws_security_group.fraud_checker.id
  referenced_security_group_id = aws_security_group.ssm_vpc_endpoint.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "lambda_to_sqs_endpoint" {
  security_group_id            = aws_security_group.backend.id
  referenced_security_group_id = aws_security_group.sqs_vpc_endpoint.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "fraud_checker_to_dynamodb_endpoint" {
  security_group_id            = aws_security_group.fraud_checker.id
  referenced_security_group_id = aws_security_group.dynamodb_vpc_endpoint.id
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
