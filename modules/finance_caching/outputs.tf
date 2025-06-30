output "elasticache_cluster_id" {
  description = "ElastiCache Cluster ID"
  value       = aws_elasticache_cluster.default.id
}

output "ssm_elasticache_url_path" {
  value       = aws_ssm_parameter.elasticache_endpoint.name
  description = "The SSM Parameter Store path for ElastiCache URL"
}
