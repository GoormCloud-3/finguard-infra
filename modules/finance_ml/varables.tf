variable "project_name" {
  description = "Project Name. It will be tagged to all resources."
  type        = string
  default     = "finguard"
}

variable "env" {
  description = "현재 인프라의 개발 환경"
  type        = string
  validation {
    condition     = anytrue([var.env == "dev", var.env == "prod", var.env == "stage"])
    error_message = "개발 환경은 'dev', 'prod', 'stage' 중 하나를 선택해주세요."
  }
}

variable "sagemaker_execution_role_arn" {
  description = "Sagemaker가 사용할 IAM Role의 ARN"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}
