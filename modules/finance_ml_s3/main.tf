resource "aws_s3_bucket" "sagemaker_bucket" {
  bucket        = "${var.project_name}-${var.env}-sagemaker-bucket"
  force_destroy = var.env == "dev" ? true : false
}
