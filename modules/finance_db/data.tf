data "aws_db_snapshot" "latest" {
  db_instance_identifier = "${var.project_name}-${var.env}-rds"
  most_recent            = true

  # 스냅샷 타입: manual or automated
  snapshot_type = "manual"
}
