mock_provider "aws" {}

run "name" {
  assert {
    condition     = output.mysql_endpoint == null
    error_message = "dd"
  }
}