resource "aws_subnet" "public_subnets" {
  for_each = var.public_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
    Name = each.key
  }
}

resource "aws_subnet" "rds_subnets" {
  for_each = var.rds_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
    Name = each.key
  }
}

resource "aws_subnet" "lambda_subnets" {
  for_each = var.lambda_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
    Name = each.key
  }
}

resource "aws_subnet" "elasticache_subnets" {
  for_each = var.elasticache_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
    Name = each.key
  }
}

resource "aws_subnet" "endpoint_subnets" {
  for_each = var.endpoint_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
    Name = each.key
  }
}
