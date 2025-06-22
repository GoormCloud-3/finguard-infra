variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "Project Name. It will be tagged to all resources."
  type = string
  default = "finguard"
}

variable "env" {
  description = "현재 인프라의 개발 환경"
  type = string
  validation {
    condition = anytrue([var.env == "dev", var.env == "prod", var.env == "stage"])
    error_message = "개발 환경은 'dev', 'prod', 'stage' 중 하나를 선택해주세요."
  }
}

variable "db_username" {
  description = "Master username for MySQL"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Master password for MySQL"
  type        = string
  sensitive   = true
  default = "test1234test!"

  validation {
    condition = (
      var.env == "dev" || var.db_password != "test1234test!"
    )
    error_message = "dev 환경이 아니면 기본 비밀번호 사용을 금지한다."
  }
}
