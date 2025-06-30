data "aws_ssm_parameter" "db_password" {
  name            = "/finguard/${local.env}/finance/rds_db_password"
  with_decryption = true
}
