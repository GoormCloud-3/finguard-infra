resource "aws_dynamodb_table" "notification" {
  name         = "${var.project_name}-${var.env}-notification-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }
}

resource "aws_ssm_parameter" "table_name" {
  name  = "/${var.project_name}/${var.env}/notification/name"
  type  = "String"
  value = aws_dynamodb_table.notification.name
}
