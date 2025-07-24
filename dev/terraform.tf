terraform {
  required_version = ">= 1.7.0"

  backend "s3" {
    bucket         = "finguard-infra"
    key            = "terraform/dev/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "terraform-lock"
    region         = "ap-northeast-2"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }
}
