module "sqs" {
  source       = "./modules/sqs"
  project_name = var.project_name
}