resource "aws_db_subnet_group" "mysql" {
  name       = "mysql-subnet-group"
  subnet_ids = var.subnet_ids
  tags = {
    Name = "${var.project_name}-rds"
  }
}

resource "aws_db_instance" "mysql" {
  identifier = "${var.project_name}-${var.env}-rds"
  # snapshot_identifier                 = data.aws_db_snapshot.latest.id
  db_name                             = var.project_name
  engine                              = "mysql"
  engine_version                      = "8.0.35"
  instance_class                      = var.instance_class
  allocated_storage                   = 20
  storage_type                        = "gp3"
  username                            = var.db_username
  password                            = var.db_password
  db_subnet_group_name                = aws_db_subnet_group.mysql.name
  vpc_security_group_ids              = [var.rds_sg_id]
  publicly_accessible                 = var.public_accessible
  multi_az                            = true
  skip_final_snapshot                 = false
  final_snapshot_identifier           = "final-${formatdate("YYYYMMDD-HHmmss", timestamp())}"
  apply_immediately                   = true
  deletion_protection                 = false
  iam_database_authentication_enabled = true
  tags = {
    Name = "${var.project_name}-rds"
  }

  lifecycle {
    ignore_changes = [
      snapshot_identifier,
      final_snapshot_identifier
    ]
  }
}

resource "aws_secretsmanager_secret" "rds_secret" {
  name = "${var.project_name}-${var.env}-db-secret"
}

# dev 환경 강제 SSM 강제 삭제용.
# 인프라 지웠다가 다시 만들면 SSM은 보존 기간이 있어서 삭제가 안됨.
# dev 환경일 시에 SSM을 보존하지 않고 강제로 삭제하게 만듬
resource "terraform_data" "force_delete_secret" {
  count = var.env == "dev" ? 1 : 0

  input = {
    secret_name = aws_secretsmanager_secret.rds_secret.name
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      echo "Force deleting secret: ${self.input.secret_name}"
      aws secretsmanager delete-secret \
        --secret-id ${self.input.secret_name} \
        --force-delete-without-recovery || true
    EOT
  }

  depends_on = [aws_secretsmanager_secret.rds_secret]
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    dbInstanceIdentifier = aws_db_instance.mysql.id,
    engine               = "mysql",
    host                 = aws_db_instance.mysql.address,
    port                 = 3306,
    username             = var.db_username
    password             = var.db_password
  })
}

resource "aws_ssm_parameter" "rds_database" {
  name  = "/${var.project_name}/${var.env}/finance/rds_db_name"
  type  = "String"
  value = aws_db_instance.mysql.db_name
}

resource "aws_ssm_parameter" "rds_username" {
  name  = "/${var.project_name}/${var.env}/finance/rds_db_username"
  type  = "String"
  value = var.db_username
}
