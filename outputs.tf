output "rds_endpoint" {
  description = "JDBC endpoint for the MySQL instance"
  sensitive   = true
  value       = aws_db_instance.mysql.endpoint
}

output "rds_endpoint_ssm" {
  description = "RDS의 엔드포인트가 SSM에 저장된 형태"
  sensitive   = true
  value       = aws_ssm_parameter.rds_endpoint.value
}

output "rds_proxy_hostname" {
  description = "RDS 프록시의 hostname"
  sensitive   = true
  value       = aws_db_proxy.mysql_proxy.endpoint
}

output "rds_proxy_endpoint_ssm" {
  description = "RDS의 엔드포인트가 SSM에 저장된 형태"
  sensitive   = true
  value       = aws_ssm_parameter.rds_proxy_endpoint.value
}