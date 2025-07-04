output "sagemaker_model_name" {
  value = aws_sagemaker_model.fraud_model.name
}

output "sagemaker_endpoint_name" {
  value = aws_sagemaker_endpoint.fraud_endpoint.name
}

output "sagemaker_endpoint_config_name" {
  value = aws_sagemaker_endpoint_configuration.fraud_config.name
}
