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

variable "subnet_ids" {
  description = "RDS가 속할 서브넷의 아이디들"
  type        = list(string)
}

variable "rds_sg_id" {
  description = "RDS가 사용할 보안그룹의 ID"
  type        = string
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
  default     = "test1234test!"

  validation {
    condition = (
      var.env == "dev" || var.db_password != "test1234test!"
    )
    error_message = "dev 환경이 아니면 기본 비밀번호 사용을 금지한다."
  }
}

variable "public_accessible" {
  description = "RDS 퍼블릭 접속 허용 여부"
  type        = bool
  default     = false
}
