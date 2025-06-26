resource "aws_vpc" "main" {
  cidr_block           = local.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.project_name
  }
}

module "sqs" {
  source               = "../modules/sqs"
  project_name         = var.project_name
  env                  = var.env
  push_lambda_role_arn = aws_iam_role.fraud_detector.arn
}

module "rds" {
  source             = "../modules/rds"
  vpc_id             = aws_vpc.main.id
  lambda_sg_id       = aws_security_group.api_lambda.id
  rds_sg_id          = aws_security_group.rds.id
  rds_proxy_sg_id    = aws_security_group.rds_proxy.id
  ssm_endpoint_sg_id = aws_security_group.ssm_vpc_endpoint.id
  kms_endpoint_sg_id = aws_security_group.kms_vpc_endpoint.id
  project_name       = var.project_name
  env                = var.env
  db_username        = var.db_username
  db_password        = var.db_password
  rds_proxy_role_arn = aws_iam_role.rds_proxy_secret_access.arn
}
