output "elasticache_cluster_id" {
  description = "ElastiCache Cluster ID"
  value       = aws_elasticache_cluster.default.id
}
