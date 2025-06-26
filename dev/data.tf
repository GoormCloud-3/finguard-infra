data "aws_caller_identity" "current" {}

data "aws_kms_key" "secretsmanager" {
  key_id = "alias/aws/secretsmanager"
}

data "aws_kms_key" "ssm" {
  key_id = "alias/aws/ssm"
}
