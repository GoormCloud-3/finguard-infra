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

variable "public_subnets" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
  description = "Public Subnet으로 IGW를 통해서 인터넷과 통신이 가능"
}

variable "rds_subnets" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
  description = "RDS가 속할 서브넷들. key는 서브넷의 이름이 된다."
}


locals {
  use_existing_rds = length(var.existing_rds_subnet_ids_map) > 0

  # 키는 "입력 변수의 키"로 고정, 값만 동적으로 결정
  rds_subnet_ids_by_key = local.use_existing_rds ? var.existing_rds_subnet_ids_map: { for k, s in aws_subnet.rds_subnets : k => s.id }
}


// 임시로 생성
variable "existing_rds_subnet_ids_map" {
  type    = map(string)
  default = {} 
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
  default     = {}
}

variable "endpoint_subnets" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
  description = "VPC Endpoint가 속할 서브넷들. key는 서브넷의 이름이 된다."
}

variable "alb_subnets" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
  description = "ALB가 속할 서브넷들. key는 서브넷의 이름이 된다."
  
}


variable "ecs_subnets" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
  description = "ECS가 속할 서브넷들. key는 서브넷의 이름이 된다."
  
}
