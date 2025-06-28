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

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "db_username" {
  description = "Master username for MySQL"
  type        = string
  default     = "admin"
}

variable "rds_resource_id" {
  description = "RDS 리소스 ID"
  type        = string
}

variable "rds_proxy_secret_arn" {
  description = "RDS Proxy Secret ARN"
  type        = string
}

variable "trade_queue_arn" {
  description = "SQS Trade Queue ARN"
  type        = string
}

variable "trade_queue_url_ssm_arn" {
  description = "SQS Trade Queue URL SSM ARN"
  type        = string
}

variable "alert_table_arn" {
  description = "DynamoDB Alert Table ARN"
  type        = string
}
