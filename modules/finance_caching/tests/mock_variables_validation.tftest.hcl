mock_provider "aws" {}

run "when_env_is_not_dev_prod_stage_then_throw_error" {
  command = plan

  variables {
    env               = "test"
    subnet_ids        = ["test1", "test2"]
    security_group_id = "test_id"
  }

  expect_failures = [
    var.env
  ]
}

run "when_sql_enginge_is_not_redis_valkey_memcached_then_throw_error" {
  command = plan

  variables {
    env               = "dev"
    subnet_ids        = ["test1", "test2"]
    security_group_id = "test_id"
    engine            = "some_strange_engine"
  }

  expect_failures = [
    var.engine
  ]
}