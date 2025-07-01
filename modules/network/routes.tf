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

resource "aws_route_table_association" "s3" {
  for_each = aws_subnet.ml_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_with_s3.id
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


# 개발 환경인 경우엔 Public Route Table을 RDS가 사용하도록
resource "aws_route_table_association" "dev_rds_subnet_with_public_route" {
  for_each = var.env == "dev" ? aws_subnet.rds_subnets : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}
