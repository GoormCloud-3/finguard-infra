# RDS Proxy 생성
resource "aws_db_proxy" "mysql_proxy" {
  name                   = "${var.project_name}-${var.env}-proxy"
  engine_family          = "MYSQL"
  vpc_subnet_ids         = var.subnet_ids
  vpc_security_group_ids = [var.rds_proxy_sg_id]
  role_arn               = var.rds_proxy_secret_access_role_arn

  auth {
    auth_scheme               = "SECRETS"
    iam_auth                  = "REQUIRED"
    secret_arn                = var.rds_secret_arn
    client_password_auth_type = "MYSQL_NATIVE_PASSWORD"
  }

  require_tls         = true
  idle_client_timeout = 1801 # 30분
  debug_logging       = true
}

resource "aws_db_proxy_target" "mysql_proxy_target" {
  db_proxy_name          = aws_db_proxy.mysql_proxy.name
  target_group_name      = "default"
  db_instance_identifier = var.rds_identifier
}

# RDS Proxy endpoint
resource "aws_ssm_parameter" "rds_proxy_endpoint" {
  name  = "/${var.project_name}/${var.env}/finance/rds_proxy_hostname"
  type  = "String"
  value = aws_db_proxy.mysql_proxy.endpoint
}
