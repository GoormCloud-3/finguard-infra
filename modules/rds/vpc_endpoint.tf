# 공통 변수
# 보안 그룹: Lambda → VPC 엔드포인트 통신용
resource "aws_security_group" "ssm_endpoint" {
  name        = "ssm-vpc-endpoint-sg"
  description = "Allow Lambda to access SSM via VPC endpoint"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.lambda_sg_id]
  }
}

# SSM 접근을 위한 VPC Endpoint
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.ap-northeast-2.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]
  security_group_ids  = [var.ssm_endpoint_sg_id]
  private_dns_enabled = true
}


# KMS 접근을 위한 VPC Endpoint
resource "aws_vpc_endpoint" "kms" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.ap-northeast-2.kms"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]
  security_group_ids  = [var.kms_endpoint_sg_id]
  private_dns_enabled = true
}

