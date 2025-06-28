data "aws_caller_identity" "current" {}

# AWS에서 SecretsManager가 사용하는 기본 Key
data "aws_kms_key" "secretsmanager" {
  key_id = "alias/aws/secretsmanager"
}

# AWS에서 SSM Parameter Store가 사용하는 기본 Key
data "aws_kms_key" "ssm" {
  key_id = "alias/aws/ssm"
}
