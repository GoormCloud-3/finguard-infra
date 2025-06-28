resource "aws_subnet" "rds_proxy_subnets" {
  for_each          = var.rds_proxy_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
    Name = each.key
  }
}

resource "aws_subnet" "rds_subnets" {
  for_each          = var.rds_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
    Name = each.key
  }
}

resource "aws_subnet" "lambda_subnets" {
  for_each          = var.lambda_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
    Name = each.key
  }
}

resource "aws_subnet" "elasticache_subnets" {
  for_each          = var.elasticache_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
    Name = each.key
  }
}

resource "aws_subnet" "ssm_endpoint_subnets" {
  for_each          = var.ssm_endpoint_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
    Name = each.key
  }
}

resource "aws_subnet" "kms_endpoint_subnets" {
  for_each          = var.kms_endpoint_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
    Name = each.key
  }
}

resource "aws_subnet" "sqs_endpoint_subnets" {
  for_each          = var.sqs_endpoint_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
    Name = each.key
  }
}

resource "aws_subnet" "sns_endpoint_subnets" {
  for_each          = var.sns_endpoint_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
    Name = each.key
  }
}
