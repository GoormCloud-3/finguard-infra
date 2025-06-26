variable "project_name" {
  description = "Project Name. It will be tagged to all resources."
  type        = string
  default     = "finguard"
}

variable "vpc_id" {
  type        = string
  description = "RDS의 서브넷이 위치할 VPC의 ID"
}

variable "env" {
  description = "현재 인프라의 개발 환경"
  type        = string

  validation {
    condition     = anytrue([var.env == "dev", var.env == "prod", var.env == "stage"])
    error_message = "개발 환경은 'dev', 'prod', 'stage' 중 하나를 선택해주세요."
  }
}

variable "rds_sg_id" {
  description = "RDS가 사용할 보안그룹의 ID"
  type        = string
}

variable "rds_proxy_sg_id" {
  description = "RDS Proxy 사용할 보안그룹의 ID"
  type        = string
}

variable "lambda_sg_id" {
  description = "RDS Proxy에 접근할 Lambda의 보안그룹 ID"
  type        = string
}

variable "ssm_endpoint_sg_id" {
  description = "SSM VPC Endpoint에 접근할 보안그룹 ID"
  type        = string
}

variable "kms_endpoint_sg_id" {
  description = "KMS VPC Endpoint에 접근할 보안그룹 ID"
  type        = string
}

variable "db_username" {
  description = "Master username for MySQL"
  type        = string
}

variable "db_password" {
  description = "Master password for MySQL"
  type        = string
  sensitive   = true
}

variable "rds_proxy_role_arn" {
  description = "RDS Proxy가 수행할 Role"
  type        = string
  sensitive   = true
}
