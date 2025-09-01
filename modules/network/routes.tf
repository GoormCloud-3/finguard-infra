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
  # for_each = aws_subnet.ecs_subnets /
  for_each      = var.ecs_subnets  
  subnet_id      = aws_subnet.ecs_subnets[each.key].id   
  route_table_id = aws_route_table.private_with_s3_and_dynamodb.id
}


resource "aws_route_table_association" "dynamodb" {
  for_each = var.lambda_subnets 

  subnet_id      = aws_subnet.lambda_subnets[each.key].id
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
  for_each = var.public_subnets

  subnet_id      = aws_subnet.public_subnets[each.key].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "alb_subnet_with_public_route" {
  for_each = var.alb_subnets

  subnet_id      = aws_subnet.alb_subnets[each.key].id
  route_table_id = aws_route_table.public_rt.id
}




# 
resource "aws_route_table_association" "dev_rds_subnet_with_public_route" {
   for_each       = var.env == "dev" ? var.rds_subnets : {}
 subnet_id      = aws_subnet.rds_subnets[each.key].id
  route_table_id = aws_route_table.public_rt.id
}


// 

resource "aws_route" "ecs_default_to_nat" {
  route_table_id         = aws_route_table.private_with_s3_and_dynamodb.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat["ap-northeast-2a"].id
  # 
}





#
# locals {
#   ecs_azs = toset([for s in aws_subnet.ecs_subnets : s.availability_zone])
# }

# # AZ蹂?ECS ?꾩슜 RT
# resource "aws_route_table" "ecs_private" {
#   for_each = local.ecs_azs
#   vpc_id   = aws_vpc.main.id
#   tags = {
#     Name = "${var.project_name}-${var.env}-ecs-private-with-s3-dynamodb-${substr(each.key,-1,1)}"
#   }
# }

# # 媛?RT??湲곕낯 寃쎈줈(/0)瑜?媛숈? AZ??NAT濡?
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
