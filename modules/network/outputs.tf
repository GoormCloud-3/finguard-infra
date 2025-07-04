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
output "sg_public" {
  description = "RDS Security Group ID"
  value       = aws_security_group.allow_all.id
}

output "sg_rds" {
  description = "RDS Security Group ID"
  value       = aws_security_group.rds.id
}

output "sg_rds_proxy" {
  description = "RDS Proxy Security Group ID"
  value       = aws_security_group.rds_proxy.id
}

output "sg_backend" {
  description = "API Lambda Security Group ID"
  value       = aws_security_group.backend.id
}

output "sg_ssm_vpc_endpoint" {
  description = "SSM VPC Endpoint Security Group ID"
  value       = aws_security_group.ssm_vpc_endpoint.id
}

output "sg_kms_vpc_endpoint" {
  description = "KMS VPC Endpoint Security Group ID"
  value       = aws_security_group.kms_vpc_endpoint.id
}

output "sg_elasticache" {
  description = "ElastiCache Security Group ID"
  value       = aws_security_group.elasticache.id
}

output "sg_sqs_vpc_endpoint" {
  description = "SQS VPC Endpoint Security Group ID"
  value       = aws_security_group.sqs_vpc_endpoint.id
}

output "sg_fraud_checker" {
  description = "sagemaker에서 위법 여부를 확인할 컴퓨팅 리소스의 보안 그룹"
  value       = aws_security_group.fraud_checker.id
}

output "sg_dynamodb_vpc_endpoint" {
  description = "DynamoDB VPC Endpoint Security Group ID"
  value       = aws_security_group.dynamodb_vpc_endpoint.id
}

output "sg_sns_vpc_endpoint" {
  description = "SNS VPC Endpoint Security Group ID"
  value       = aws_security_group.sns_vpc_endpoint.id
}
