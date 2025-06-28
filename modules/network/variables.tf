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

variable "main_vpc_cidr_block" {
  type        = string
  description = "main VPC의 cidr_block"
}

variable "rds_subnets" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
  description = "RDS가 속할 서브넷들. key는 서브넷의 이름이 된다."
}

variable "rds_proxy_subnets" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
  description = "RDS Proxy가 속할 서브넷들. key는 서브넷의 이름이 된다."
}

variable "lambda_subnets" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
  description = "API Lambda가 속할 서브넷들. key는 서브넷의 이름이 된다."
}

variable "elasticache_subnets" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
  description = "ElastiCache가 속할 서브넷들. key는 서브넷의 이름이 된다."
}

variable "ssm_endpoint_subnets" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
  description = "SSM VPC Endpoint가 속할 서브넷들. key는 서브넷의 이름이 된다."
}

variable "kms_endpoint_subnets" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
  description = "kms VPC Endpoint가 속할 서브넷들. key는 서브넷의 이름이 된다."
}

variable "sqs_endpoint_subnets" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
  description = "SQS VPC Endpoint가 속할 서브넷들. key는 서브넷의 이름이 된다."
}

variable "sns_endpoint_subnets" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
  description = "SNS VPC Endpoint가 속할 서브넷들. key는 서브넷의 이름이 된다."
}
