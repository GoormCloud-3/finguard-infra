resource "aws_subnet" "public_subnets" {
  for_each = var.public_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
    Name = each.key
  }
}

# resource "aws_subnet" "rds_subnets" {
#   for_each = var.rds_subnets

#   vpc_id            = aws_vpc.main.id
#   cidr_block        = each.value.cidr_block
#   availability_zone = each.value.az
#   tags = {
#     Name = each.key
#   }
# }

// 임시 생성

resource "aws_subnet" "rds_subnets" {
  for_each         = local.use_existing_rds ? {} : var.rds_subnets
  vpc_id           = aws_vpc.main.id
  cidr_block       = each.value.cidr_block
  availability_zone= each.value.az
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

resource "aws_subnet" "alb_subnets" {
  for_each = var.alb_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  map_public_ip_on_launch = true   # 퍼블릭 IP 자동 할당
  tags = {
    Name = each.key
  }
}

resource "aws_subnet" "ecs_subnets" {
  for_each = var.ecs_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
    Name = each.key
  }
}