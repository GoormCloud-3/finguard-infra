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

resource "aws_route_table_association" "dynamodb" {
  for_each = aws_subnet.lambda_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_with_dynamodb.id
}

# Route Table
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

resource "aws_route_table_association" "igw" {
  for_each = aws_subnet.public_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "dev_rds" {
  for_each = var.env == "dev" ? aws_subnet.rds_subnets : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}
