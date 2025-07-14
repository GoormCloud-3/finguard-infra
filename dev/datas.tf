data "aws_s3_bucket" "ml_model_bucket" {
  bucket = "${local.project_name}-fraud-model"
}