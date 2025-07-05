resource "aws_elasticache_subnet_group" "caching" {
  name        = "${var.project_name}-${var.env}-account"
  subnet_ids  = var.subnet_ids
  description = "Elasticache subnet group for account"
}

resource "aws_elasticache_cluster" "default" {
  cluster_id           = "${var.project_name}-${var.env}-account"
  engine               = var.engine
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = "default.redis7"
  subnet_group_name    = aws_elasticache_subnet_group.caching.name
  security_group_ids   = [var.security_group_id]
  port                 = 6379

  tags = {
    Name = "${var.project_name}-${var.env}-account"
  }
}

resource "aws_ssm_parameter" "elasticache_endpoint" {
  name  = "/${var.project_name}/${var.env}/finance/redis_host"
  type  = "String"
  value = aws_elasticache_cluster.default.cache_nodes[0].address
}
