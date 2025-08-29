# locals {
#   # az => public subnet id
#   public_subnet_id_by_az = {
#     for k, s in aws_subnet.public_subnets : s.availability_zone => s.id
#   }


#   nat_azs = toset(["ap-northeast-2a", "ap-northeast-2c"])
# }


# resource "aws_eip" "nat" {
#   for_each = local.nat_azs
#   domain   = "vpc"
#   tags = {
#     Name = "${var.project_name}-${var.env}-nat-eip-${substr(each.key, -1, 1)}"
#   }
# }


# resource "aws_nat_gateway" "nat" {
#   for_each      = local.nat_azs
#   allocation_id = aws_eip.nat[each.key].id
#   subnet_id     = local.public_subnet_id_by_az[each.key]
#   tags = {
#     Name = "${var.project_name}-${var.env}-nat-${substr(each.key, -1, 1)}"
#   }
# }