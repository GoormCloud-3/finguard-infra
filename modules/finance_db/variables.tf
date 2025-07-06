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

  validation {
    condition     = length(var.subnet_ids) >= 1
    error_message = "RDS의 서브넷은 최소 1개 이상 필요합니다."
  }
}

variable "rds_sg_id" {
  description = "RDS가 사용할 보안그룹의 ID"
  type        = string

  validation {
    condition     = length(var.rds_sg_id) > 0
    error_message = "rds_sg_id의 내용이 비었습니다."
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
}

variable "public_accessible" {
  description = "RDS 퍼블릭 접속 허용 여부"
  type        = bool
  default     = false
}
