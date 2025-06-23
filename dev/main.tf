module "sqs" {
  source       = "../modules/sqs"
  project_name = var.project_name
  env          = var.env
}

module "rds" {
  source       = "../modules/rds"
  project_name = var.project_name
  env          = var.env
  db_username  = var.db_username
  db_password  = var.db_password
}