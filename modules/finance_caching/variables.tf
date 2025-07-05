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

variable "engine" {
  description = "Engine type (redis or memcached)"
  type        = string
  default     = "redis"

  validation {
    condition     = contains(["redis", "valkey", "memcached"], var.engine)
    error_message = "Elasticache의 엔진은 'redis', 'valkey', 'memcached' 중 하나만 가능합니다."
  }
}

variable "node_type" {
  description = "Elasticache instance type"
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_nodes" {
  description = "Elasticache 노드의 개수 (for Redis set to 1)"
  type        = number
  default     = 1
}

variable "subnet_ids" {
  description = "Elasticache가 사용할 서브넷들"
  type        = list(string)
}

variable "security_group_id" {
  description = "Elasticache가 사용할 보안그룹"
  type        = string
}
