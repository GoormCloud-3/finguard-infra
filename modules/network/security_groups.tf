resource "aws_security_group" "rds" {
  name   = "${var.project_name}-${var.env}-rds"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "rds_proxy" {
  name   = "${var.project_name}-${var.env}-rds-proxy"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "api_lambda" {
  name   = "${var.project_name}-${var.env}-api-lambda"
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

resource "aws_security_group" "elasticache" {
  name   = "${var.project_name}-${var.env}-elasticache"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "sqs_vpc_endpoint" {
  name   = "${var.project_name}-${var.env}-sqs-vpc-endpoint"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "alert_lambda" {
  name   = "${var.project_name}-${var.env}-alert-lambda"
  vpc_id = aws_vpc.main.id
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

resource "aws_vpc_security_group_ingress_rule" "rds_proxy_from_lambda" {
  security_group_id            = aws_security_group.rds_proxy.id
  referenced_security_group_id = aws_security_group.api_lambda.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "elasticache_from_lambda" {
  security_group_id            = aws_security_group.elasticache.id
  referenced_security_group_id = aws_security_group.api_lambda.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ssm_endpoint_from_lambda" {
  security_group_id            = aws_security_group.ssm_vpc_endpoint.id
  referenced_security_group_id = aws_security_group.api_lambda.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "kms_endpoint_from_lambda" {
  security_group_id            = aws_security_group.kms_vpc_endpoint.id
  referenced_security_group_id = aws_security_group.api_lambda.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "sqs_endpoint_from_lambda" {
  security_group_id            = aws_security_group.sqs_vpc_endpoint.id
  referenced_security_group_id = aws_security_group.api_lambda.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "dynamodb_endpoint_from_alert_lambda" {
  security_group_id            = aws_security_group.dynamodb_vpc_endpoint.id
  referenced_security_group_id = aws_security_group.alert_lambda.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "sns_endpoint_from_alert_lambda" {
  security_group_id            = aws_security_group.sns_vpc_endpoint.id
  referenced_security_group_id = aws_security_group.alert_lambda.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

# === Egress Rules ===
resource "aws_vpc_security_group_egress_rule" "lambda_to_rds_proxy" {
  security_group_id            = aws_security_group.api_lambda.id
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
  security_group_id            = aws_security_group.api_lambda.id
  referenced_security_group_id = aws_security_group.elasticache.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "lambda_to_endpoints" {
  security_group_id            = aws_security_group.api_lambda.id
  referenced_security_group_id = aws_security_group.ssm_vpc_endpoint.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "lambda_to_sqs_endpoint" {
  security_group_id            = aws_security_group.api_lambda.id
  referenced_security_group_id = aws_security_group.sqs_vpc_endpoint.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alert_lambda_to_dynamodb_endpoint" {
  security_group_id            = aws_security_group.alert_lambda.id
  referenced_security_group_id = aws_security_group.dynamodb_vpc_endpoint.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alert_lambda_to_sns_endpoint" {
  security_group_id            = aws_security_group.alert_lambda.id
  referenced_security_group_id = aws_security_group.sns_vpc_endpoint.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
