output "rds_identifier" {
  description = "RDS의 식별자"
  value       = aws_db_instance.mysql.identifier
}

output "rds_endpoint" {
  description = "JDBC endpoint for the MySQL instance"
  sensitive   = true
  value       = aws_db_instance.mysql.endpoint
}

output "rds_resource_id" {
  description = "rds의 resource id"
  sensitive   = true
  value       = aws_db_instance.mysql.resource_id
}

# RDS Proxy Secrets Manager
output "rds_secret_arn" {
  value       = aws_secretsmanager_secret.rds_secret.arn
  description = "RDS Proxy가 RDS에 접속하기 위해 사용하는 rds의 Secret 정보"
  sensitive   = true
}
