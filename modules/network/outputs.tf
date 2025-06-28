output "main_vpc_id" {
  description = "main vpc의 ID"
  value       = aws_vpc.main.id
}

output "rds_subnet_ids" {
  description = "RDS 서브넷들의 ID"
  value       = [for s in aws_subnet.rds_subnets : s.id]
}

output "rds_proxy_subnet_ids" {
  description = "RDS Proxy 서브넷들의 ID"
  value       = [for s in aws_subnet.rds_proxy_subnets : s.id]
}

output "lambda_subnet_ids" {
  description = "Lambda 서브넷들의 ID"
  value       = [for s in aws_subnet.lambda_subnets : s.id]
}

output "elasticache_subnet_ids" {
  description = "ElastiCache 서브넷들의 ID"
  value       = [for s in aws_subnet.elasticache_subnets : s.id]
}

output "ssm_endpoint_subnet_ids" {
  description = "SSM VPC Endpoint용 서브넷들의 ID"
  value       = [for s in aws_subnet.ssm_endpoint_subnets : s.id]
}

output "sqs_endpoint_subnet_ids" {
  description = "SQS VPC Endpoint용 서브넷들의 ID"
  value       = [for s in aws_subnet.sqs_endpoint_subnets : s.id]
}

output "sns_endpoint_subnet_ids" {
  description = "SNS VPC Endpoint용 서브넷들의 ID"
  value       = [for s in aws_subnet.sns_endpoint_subnets : s.id]
}

# 보안그룹
output "sg_rds" {
  description = "RDS Security Group ID"
  value       = aws_security_group.rds.id
}

output "sg_rds_proxy" {
  description = "RDS Proxy Security Group ID"
  value       = aws_security_group.rds_proxy.id
}

output "sg_api_lambda" {
  description = "API Lambda Security Group ID"
  value       = aws_security_group.api_lambda.id
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

output "sg_alert_lambda" {
  description = "Alert Lambda Security Group ID"
  value       = aws_security_group.alert_lambda.id
}

output "sg_dynamodb_vpc_endpoint" {
  description = "DynamoDB VPC Endpoint Security Group ID"
  value       = aws_security_group.dynamodb_vpc_endpoint.id
}

output "sg_sns_vpc_endpoint" {
  description = "SNS VPC Endpoint Security Group ID"
  value       = aws_security_group.sns_vpc_endpoint.id
}
