resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-2.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.ssm_endpoint_subnets : s.id]
  security_group_ids  = [aws_security_group.ssm_vpc_endpoint.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "kms" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-2.kms"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.kms_endpoint_subnets : s.id]
  security_group_ids  = [aws_security_group.kms_vpc_endpoint.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "sns" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-2.sns"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.sns_endpoint_subnets : s.id]
  security_group_ids  = [aws_security_group.sns_vpc_endpoint.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "sqs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-2.sqs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.sqs_endpoint_subnets : s.id]
  security_group_ids  = [aws_security_group.sqs_vpc_endpoint.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-2.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [
    aws_route_table.private_with_dynamodb.id
  ]
}
