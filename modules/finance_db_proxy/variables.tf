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

variable "rds_identifier" {
  description = "RDS Proxy가 접근할 RDS의 Identifier"
  type        = string
}

variable "rds_proxy_secret_access_role_arn" {
  description = "RDS Proxy가 Secret에 접근 가능하게 만드는 Role"
  type        = string
}

variable "subnet_ids" {
  description = "RDS Proxy가 속할 Subnet들의 ID"
  type        = list(string)
}

variable "rds_proxy_sg_id" {
  description = "RDS Proxy가 사용할 보안그룹의 ID"
  type        = string
}

variable "rds_secret_arn" {
  description = "RDS Proxy가 RDS에 접속하기 위해 필요한 Secret의 ARN"
  type        = string
}
