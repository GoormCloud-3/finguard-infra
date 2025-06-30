locals {
  project_name = "finguard"
  env          = "dev"
  db_username  = "admin"
  region       = "ap-northeast-2"

  caching = {
    node_type       = "cache.t3.micro"
    num_cache_nodes = 1
  }
}
