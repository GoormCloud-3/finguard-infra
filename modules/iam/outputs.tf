output "fraud_detector_role_arn" {
  value = aws_iam_role.fraud_detector.arn
}

output "rds_proxy_secret_access_role_arn" {
  value = aws_iam_role.rds_proxy_secret_access.arn
}

output "sagemaker_execution_role_arn" {
  value = aws_iam_role.sagemaker_execution_role.arn
}
