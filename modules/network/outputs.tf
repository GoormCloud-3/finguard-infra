output "main_vpc_id" {
  description = "main vpc의 ID"
  value       = aws_vpc.main.id
}

output "rds_subnet_ids" {
  description = "RDS 서브넷들의 ID"
  value       = [for s in aws_subnet.rds_subnets : s.id]
}

output "lambda_subnet_ids" {
  description = "Lambda 서브넷들의 ID"
  value       = [for s in aws_subnet.lambda_subnets : s.id]
}

output "elasticache_subnet_ids" {
  description = "ElastiCache 서브넷들의 ID"
  value       = [for s in aws_subnet.elasticache_subnets : s.id]
}

output "endpoint_subnet_ids" {
  description = "VPC Endpoint용 서브넷들의 ID"
  value       = [for s in aws_subnet.endpoint_subnets : s.id]
}

# 보안그룹
output "public_sg_id" {
  description = "Public Security Group ID"
  value       = aws_security_group.allow_all.id
}

output "rds_sg_id" {
  description = "RDS Security Group ID"
  value       = aws_security_group.rds.id
}

output "rds_proxy_sg_id" {
  description = "RDS Proxy Security Group ID"
  value       = aws_security_group.rds_proxy.id
}

output "backend_sg_id" {
  description = "API Lambda Security Group ID"
  value       = aws_security_group.backend.id
}

output "ssm_vpc_endpoint_sg_id" {
  description = "SSM VPC Endpoint Security Group ID"
  value       = aws_security_group.ssm_vpc_endpoint.id
}

output "kms_vpc_endpoint_sg_id" {
  description = "KMS VPC Endpoint Security Group ID"
  value       = aws_security_group.kms_vpc_endpoint.id
}

output "elasticache_sg_id" {
  description = "ElastiCache Security Group ID"
  value       = aws_security_group.elasticache.id
}

output "sqs_vpc_endpoint_sg_id" {
  description = "SQS VPC Endpoint Security Group ID"
  value       = aws_security_group.sqs_vpc_endpoint.id
}

output "fraud_checker_sg_id" {
  description = "Fraud checker computing resource Security Group ID"
  value       = aws_security_group.fraud_checker.id
}

output "dynamodb_vpc_endpoint_sg_id" {
  description = "DynamoDB VPC Endpoint Security Group ID"
  value       = aws_security_group.dynamodb_vpc_endpoint.id
}

output "sns_vpc_endpoint_sg_id" {
  description = "SNS VPC Endpoint Security Group ID"
  value       = aws_security_group.sns_vpc_endpoint.id
}
