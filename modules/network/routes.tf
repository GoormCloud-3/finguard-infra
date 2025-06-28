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
