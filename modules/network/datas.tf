data "aws_prefix_list" "dynamodb" {
  name = "com.amazonaws.ap-northeast-2.dynamodb"
}

data "aws_prefix_list" "s3" {
  name = "com.amazonaws.ap-northeast-2.s3"
}