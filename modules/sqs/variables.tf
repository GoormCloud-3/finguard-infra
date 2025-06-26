variable "project_name" {
  description = "리소스의 Prefix로 붙을 프로젝트명"
  type        = string
}

variable "env" {
  description = "현재 인프라의 개발 환경"
  type        = string
  validation {
    condition     = anytrue([var.env == "dev", var.env == "prod", var.env == "stage"])
    error_message = "개발 환경은 'dev', 'prod', 'stage' 중 하나를 선택해주세요."
  }
}

variable "push_lambda_role_arn" {
  description = "SQS를 사용할 Lambda의 Role의 ARN"
  type        = string
}
