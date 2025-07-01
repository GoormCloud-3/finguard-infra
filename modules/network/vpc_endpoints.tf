resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-2.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.endpoint_subnets : s.id]
  security_group_ids  = [aws_security_group.ssm_vpc_endpoint.id]
  private_dns_enabled = true
  tags = {
    Name = "${var.project_name}-${var.env}-ssm"
  }
}

resource "aws_vpc_endpoint" "kms" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-2.kms"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.endpoint_subnets : s.id]
  security_group_ids  = [aws_security_group.kms_vpc_endpoint.id]
  private_dns_enabled = true
  tags = {
    Name = "${var.project_name}-${var.env}-kms"
  }
}

resource "aws_vpc_endpoint" "sns" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-2.sns"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.endpoint_subnets : s.id]
  security_group_ids  = [aws_security_group.sns_vpc_endpoint.id]
  private_dns_enabled = true
  tags = {
    Name = "${var.project_name}-${var.env}-sns"
  }
}

resource "aws_vpc_endpoint" "sqs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-2.sqs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.endpoint_subnets : s.id]
  security_group_ids  = [aws_security_group.sqs_vpc_endpoint.id]
  private_dns_enabled = true
  tags = {
    Name = "${var.project_name}-${var.env}-sqs"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.ap-northeast-2.ecr.api"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [for s in aws_subnet.endpoint_subnets : s.id]
  security_group_ids = [aws_security_group.ecr_vpc_endpoint.id]
  tags = {
    Name = "${var.project_name}-${var.env}-ecr-api"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.ap-northeast-2.ecr.dkr"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [for s in aws_subnet.endpoint_subnets : s.id]
  security_group_ids = [aws_security_group.ecr_vpc_endpoint.id]
  tags = {
    Name = "${var.project_name}-${var.env}-ecr-dkr"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-2.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [
    aws_route_table.private_with_s3.id
  ]

  tags = {
    Name = "${var.project_name}-${var.env}-s3-endpoint"
  }
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-2.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [
    aws_route_table.private_with_dynamodb.id
  ]
  tags = {
    Name = "${var.project_name}-${var.env}-dynamodb"
  }
}
