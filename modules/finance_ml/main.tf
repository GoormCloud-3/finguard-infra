resource "aws_sagemaker_model" "fraud_model" {
  name               = "${var.project_name}-${var.env}-fraud-model"
  execution_role_arn = var.sagemaker_execution_role_arn

  primary_container {
    image          = "${data.aws_ecr_repository.fraud_check.repository_url}:${var.env}"
    mode           = "SingleModel"
    model_data_url = "s3://${var.bucket_name}/models/${var.env}/fraud-model.tar.gz"
    environment = {
      SAGEMAKER_PROGRAM = "serve.py"
      SAGEMAKER_REGION  = "ap-northeast-2"
    }
  }
}

resource "aws_sagemaker_endpoint_configuration" "fraud_config" {
  name = "${var.project_name}-${var.env}-fraud-config"

  production_variants {
    variant_name = "AllTraffic"
    model_name   = aws_sagemaker_model.fraud_model.name
    serverless_config {
      memory_size_in_mb = 1024
      max_concurrency   = 10
    }
  }
}

resource "aws_sagemaker_endpoint" "fraud_endpoint" {
  name                 = "${var.project_name}-${var.env}-fraud-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.fraud_config.name
}

resource "aws_ssm_parameter" "endpoint" {
  name  = "/${var.project_name}/${var.env}/finance/fraud_sage_maker_endpoint_name"
  type  = "String"
  value = aws_sagemaker_endpoint.fraud_endpoint.name
}
