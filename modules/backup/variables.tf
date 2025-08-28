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
variable "region"       { type = string }

# Vault & 암호화
variable "kms_key_arn"  { 
    type = string
    default = null 
}

# 스케줄(KST 03:00 = UTC 18:00)
variable "schedule_cron" {
  type        = string
  default     = "cron(0 18 * * ? *)"
  description = "AWS Backup cron (UTC). 예: KST 03:00 = cron(0 18 * * ? *)"
}

# 보존정책
variable "cold_storage_after_days" { 
    type = number 
    default = 30 
}
variable "retention_days"          { 
    type = number
    default = 125 
    validation {
      condition     = var.retention_days - var.cold_storage_after_days >= 90
      error_message = "retention_days must be at least cold_storage_after_days + 90."
    }
}
variable "start_window_minutes"    { 
    type = number 
    default = 60 
}
variable "completion_window_minutes" { 
    type = number 
    default = 240 
}

# 태그 기반 선택
variable "selection_tag_key"   { 
    type = string
    default = "backup" 
}
variable "selection_tag_value" { 
    type = string
    default = "daily" 
}

variable "destination_vault_arn" {
  type    = string
  default = null
}

variable "resource_arns" {
  type    = list(string)
  default = []   # 아무 것도 안 넘기면 빈 리스트
}

variable "iam_role_arn" {
  type = string
}