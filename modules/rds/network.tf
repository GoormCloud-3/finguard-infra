resource "aws_route_table" "private" {
  vpc_id = var.vpc_id
  tags   = { Name = "${var.project_name}-private-rt" }
}

resource "aws_subnet" "private" {
  count             = length(local.private_subnet_cidrs)
  vpc_id            = var.vpc_id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.project_name}-private-${count.index + 1}"
  }
}
