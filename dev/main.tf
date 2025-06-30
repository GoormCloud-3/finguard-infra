module "network" {
  source = "../modules/network"

  project_name        = local.project_name
  env                 = local.env
  main_vpc_cidr_block = "10.0.0.0/16"
  public_subnets = {
    "${local.project_name}-${local.env}-public-a" = { cidr_block = "10.0.1.0/24", az = "ap-northeast-2a" }
    "${local.project_name}-${local.env}-public-c" = { cidr_block = "10.0.2.0/24", az = "ap-northeast-2c" }
  }
  rds_subnets = {
    "${local.project_name}-${local.env}-rds-a" = { cidr_block = "10.0.11.0/24", az = "ap-northeast-2a" }
    "${local.project_name}-${local.env}-rds-c" = { cidr_block = "10.0.12.0/24", az = "ap-northeast-2c" }
  }
  lambda_subnets = {
    "${local.project_name}-${local.env}-lambda-a" = { cidr_block = "10.0.21.0/24", az = "ap-northeast-2a" }
    "${local.project_name}-${local.env}-lambda-c" = { cidr_block = "10.0.22.0/24", az = "ap-northeast-2c" }
  }
  elasticache_subnets = {
    "${local.project_name}-${local.env}-elasticache-a" = { cidr_block = "10.0.31.0/24", az = "ap-northeast-2a" }
    "${local.project_name}-${local.env}-elasticache-c" = { cidr_block = "10.0.32.0/24", az = "ap-northeast-2c" }
  }
  endpoint_subnets = {
    "${local.project_name}-${local.env}-vpc-endpoint-a" = { cidr_block = "10.0.41.0/24", az = "ap-northeast-2a" }
    "${local.project_name}-${local.env}-vpc-endpoint-c" = { cidr_block = "10.0.42.0/24", az = "ap-northeast-2c" }
  }
}

module "iam" {
  source = "../modules/iam"

  region       = local.region
  project_name = local.project_name
  env          = local.env
  db_username  = local.db_username

  # RDS 모듈에서 필요한 값
  rds_proxy_secret_arn = module.trading_rds.rds_secret_arn

  # SQS 모듈에서 필요한 값
  trade_queue_arn = module.trading_sqs.trade_queue_arn

  # DynamoDB 모듈에서 필요한 값
  alert_table_arn = module.notification_token_table.table_arn
}

module "trading_sqs" {
  source = "../modules/finance_trading_queue"

  project_name = local.project_name
  env          = local.env
}

module "trading_rds" {
  source = "../modules/finance_db"

  project_name      = local.project_name
  env               = local.env
  subnet_ids        = module.network.rds_subnet_ids
  rds_sg_id         = module.network.sg_rds
  db_username       = local.db_username
  public_accessible = true
}

module "trading_rds_proxy" {
  source = "../modules/finance_db_proxy"

  project_name                     = local.project_name
  env                              = local.env
  subnet_ids                       = module.network.rds_subnet_ids
  rds_proxy_sg_id                  = module.network.sg_rds_proxy
  rds_proxy_secret_access_role_arn = module.iam.rds_proxy_secret_access_role_arn
  rds_secret_arn                   = module.trading_rds.rds_secret_arn
  rds_identifier                   = module.trading_rds.rds_identifier
}

module "notification_token_table" {
  source = "../modules/finance_noti_table"

  project_name = local.project_name
  env          = local.env
}

module "caching" {
  source = "../modules/finance_caching"

  cluster_id        = "account"
  project_name      = local.project_name
  env               = local.env
  security_group_id = module.network.sg_elasticache
  subnet_ids        = module.network.elasticache_subnet_ids
  node_type         = local.caching.node_type
  num_cache_nodes   = local.caching.num_cache_nodes
}
