mock_provider "aws" {}

run "when_env_is_not_dev_prod_stage_then_throw_error" {
  command = plan

  variables {
    env = "test"
    subnet_ids = ["test1", "test2"]
    rds_sg_id = "sg-id"
    db_password = "test"
  }

  expect_failures = [ 
    var.env
  ]  
}

run "when_subnet_ids_is_empty_then_fail" {
  command = plan

  variables {
    env               = "dev"
    subnet_ids        = []
    rds_sg_id         = "sg-123"
    db_password       = "secure123"
    public_accessible = false
  }

  expect_failures = [var.subnet_ids]
}

run "when_rds_sg_id_is_empty_then_fail" {
  command = plan

  variables {
    env               = "dev"
    subnet_ids        = ["subnet-1"]
    rds_sg_id         = ""
    db_password       = "secure123"
    public_accessible = false
  }

  expect_failures = [var.rds_sg_id]
}