variable "finance_db_password" {
  description = "finance DB에서 사용할 비밀번호"
  sensitive   = true
  type        = string
}