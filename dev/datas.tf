data "aws_ssm_parameter" "db_password" {
  name            = "/finguard/${local.env}/finance/rds_db_password"
  with_decryption = true
}

data "aws_s3_bucket" "ml_model_bucket" {
  bucket = "${local.project_name}-fraud-model"
}
