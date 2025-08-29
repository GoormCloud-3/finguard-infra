resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.env}-private"
  }
}

resource "aws_route_table" "private_with_dynamodb" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.env}-private-with-dynamodb"
  }
}

resource "aws_route_table" "private_with_s3" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.env}-private-with-s3"
  }
}

resource "aws_route_table" "private_with_s3_and_dynamodb" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.env}-private-with-S3-And-Dynamodb"
  }
}

resource "aws_route_table_association" "ecs" {
  for_each = aws_subnet.ecs_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_with_s3_and_dynamodb.id
}


resource "aws_route_table_association" "dynamodb" {
  for_each = aws_subnet.lambda_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_with_dynamodb.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-${var.env}-public"
  }
}

resource "aws_route" "public_igw_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_subnet_with_public_route" {
  for_each = aws_subnet.public_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "alb_subnet_with_public_route" {
  for_each = aws_subnet.alb_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}




# 개발 환경인 경우엔 Public Route Table을 RDS가 사용하도록
resource "aws_route_table_association" "dev_rds_subnet_with_public_route" {
  for_each = var.env == "dev" ? aws_subnet.rds_subnets : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}


// 일단 최소 변경사항 적용.

resource "aws_route" "ecs_default_to_nat" {
  route_table_id         = aws_route_table.private_with_s3_and_dynamodb.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat["ap-northeast-2a"].id
  # 필요하면 위 키를 "ap-northeast-2c"로 바꿔서 c AZ NAT를 타게 할 수 있음
}



// 아래는 az별로 ecs용 라우팅 테이블 생성하는 코드

# # ECS 서브넷이 실제로 배치된 AZ 집합
# locals {
#   ecs_azs = toset([for s in aws_subnet.ecs_subnets : s.availability_zone])
# }

# # AZ별 ECS 전용 RT
# resource "aws_route_table" "ecs_private" {
#   for_each = local.ecs_azs
#   vpc_id   = aws_vpc.main.id
#   tags = {
#     Name = "${var.project_name}-${var.env}-ecs-private-with-s3-dynamodb-${substr(each.key,-1,1)}"
#   }
# }

# # 각 RT의 기본 경로(/0)를 같은 AZ의 NAT로
# resource "aws_route" "ecs_default" {
#   for_each               = local.ecs_azs
#   route_table_id         = aws_route_table.ecs_private[each.key].id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.nat[each.key].id
# }

# locals {
#   ecs_subnet_map = {
#     for name, s in aws_subnet.ecs_subnets : name => { id = s.id, az = s.availability_zone }
#   }
# }

# resource "aws_route_table_association" "ecs_by_az" {
#   for_each       = local.ecs_subnet_map
#   subnet_id      = each.value.id
#   route_table_id = aws_route_table.ecs_private[each.value.az].id
# }