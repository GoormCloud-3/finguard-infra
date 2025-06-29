provider "aws" {
  default_tags {
    tags = {
      Project = var.project_name
      Env     = var.env
    }
  }
}
