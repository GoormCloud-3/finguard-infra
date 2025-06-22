# 공통 변수
# 보안 그룹: Lambda → VPC 엔드포인트 통신용
resource "aws_security_group" "ssm_endpoint" {
  name        = "ssm-vpc-endpoint-sg"
  description = "Allow Lambda to access SSM via VPC endpoint"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [ aws_security_group.dao.id ]
  }
}

# SSM 접근을 위한 VPC Endpoint
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-2.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [for subnet in aws_subnet.private: subnet.id]
  security_group_ids = [aws_security_group.ssm_endpoint.id]
  private_dns_enabled = true
}

resource "aws_security_group" "kms_endpoint" {
  name        = "kms-vpc-endpoint-sg"
  description = "Allow Lambda to access kms via VPC endpoint"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [ aws_security_group.dao.id ]
  }
}
# KMS 접근을 위한 VPC Endpoint
resource "aws_vpc_endpoint" "kms" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-2.kms"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [for subnet in aws_subnet.private: subnet.id]
  security_group_ids = [aws_security_group.kms_endpoint.id]
  private_dns_enabled = true
}