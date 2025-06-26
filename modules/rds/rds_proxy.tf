# RDS Proxy 생성
resource "aws_db_proxy" "mysql_proxy" {
  name                   = "${var.project_name}-proxy"
  engine_family          = "MYSQL"
  role_arn               = var.rds_proxy_role_arn
  vpc_subnet_ids         = [for subnet in aws_subnet.private : subnet.id]
  vpc_security_group_ids = [var.rds_proxy_sg_id]

  auth {
    auth_scheme               = "SECRETS"
    iam_auth                  = "REQUIRED"
    secret_arn                = aws_secretsmanager_secret.rds_secret.arn
    client_password_auth_type = "MYSQL_NATIVE_PASSWORD"
  }

  require_tls         = true
  idle_client_timeout = 1801 # 30분
  debug_logging       = true
}

resource "aws_db_proxy_target" "mysql_proxy_target" {
  db_proxy_name          = aws_db_proxy.mysql_proxy.name
  target_group_name      = "default"
  db_instance_identifier = aws_db_instance.mysql.identifier
}

# RDS Proxy endpoint
resource "aws_ssm_parameter" "rds_proxy_endpoint" {
  name  = "/${var.project_name}/finance/rds_proxy"
  type  = "String"
  value = aws_db_proxy.mysql_proxy.endpoint
}
