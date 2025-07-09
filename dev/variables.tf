variable "env" {
  description = "현재 인프라의 개발 환경"
  type        = string

  validation {
    condition     = anytrue([var.env == "dev", var.env == "prod", var.env == "stage"])
    error_message = "개발 환경은 'dev', 'prod', 'stage' 중 하나를 선택해주세요."
  }
}

variable "db_password" {
  description = "Master password for MySQL"
  type        = string
  sensitive   = true

  validation {
    condition = (
      var.env == "dev" || var.db_password != "test1234test!"
    )
    error_message = "dev 환경이 아니면 기본 비밀번호 사용을 금지한다."
  }
}
