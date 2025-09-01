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
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-2.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [for s in aws_subnet.endpoint_subnets : s.id]

  // 새로 만들어진 vpce 보안그룹 추가
  security_group_ids = [
    aws_security_group.ecr_api_endpoint.id
  ]
  private_dns_enabled = true
  tags = {
    Name = "${var.project_name}-${var.env}-ecr-api"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-2.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [for s in aws_subnet.endpoint_subnets : s.id]
  // 새로 만들어진 vpce 보안그룹 추가
  security_group_ids = [
    aws_security_group.ecr_dkr_endpoint.id
  ]
  private_dns_enabled = true
  tags = {
    Name = "${var.project_name}-${var.env}-ecr-dkr"
  }
}


resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-2.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.endpoint_subnets : s.id]
  security_group_ids  = [aws_security_group.cloudwatch_logs_endpoint.id]
  private_dns_enabled = true
  tags = {
    Name = "${var.project_name}-${var.env}-cloudwatch"
  }
}

resource "aws_vpc_endpoint" "sagemaker_runtime" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-2.sagemaker.runtime"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.endpoint_subnets : s.id]
  security_group_ids  = [aws_security_group.sagemaker_runtime_endpoint.id]
  private_dns_enabled = true
  tags = {
    Name = "${var.project_name}-${var.env}-sagemaker-runtime"
  }
}

resource "aws_vpc_endpoint" "xray" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-2.xray"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.endpoint_subnets : s.id]
  security_group_ids  = [aws_security_group.xray_endpoint.id]
  private_dns_enabled = true
  tags = {
    Name = "${var.project_name}-${var.env}-xray"
  }
}


resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-2.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [
    aws_route_table.private_with_s3.id,
    aws_route_table.private_with_s3_and_dynamodb.id
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
    aws_route_table.private_with_dynamodb.id,
    aws_route_table.private_with_s3_and_dynamodb.id
  ]
  tags = {
    Name = "${var.project_name}-${var.env}-dynamodb"
  }
}

