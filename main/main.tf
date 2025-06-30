module "network" {
  source = "../modules/network"

  project_name        = local.project_name
  env                 = local.env
  main_vpc_cidr_block = local.main_vpc_cidr_block
  public_subnets      = local.public_subnets
  rds_subnets         = local.rds_subnets
  lambda_subnets      = local.lambda_subnets
  elasticache_subnets = local.elasticache_subnets
  endpoint_subnets    = local.endpoint_subnets
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
  db_password       = data.aws_ssm_parameter.db_password.value
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
