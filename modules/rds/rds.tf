resource "aws_db_subnet_group" "mysql" {
  name       = "mysql-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]
  tags = {
    Name = "${var.project_name}-rds"
  }
}

resource "aws_db_instance" "mysql" {
  identifier                          = "${var.project_name}-rds"
  db_name                             = var.project_name
  engine                              = "mysql"
  engine_version                      = "8.0.36"
  instance_class                      = "db.t4g.micro"
  allocated_storage                   = 20
  storage_type                        = "gp3"
  username                            = var.db_username
  password                            = var.db_password
  db_subnet_group_name                = aws_db_subnet_group.mysql.name
  vpc_security_group_ids              = [var.rds_sg_id]
  publicly_accessible                 = false
  multi_az                            = true
  skip_final_snapshot                 = true
  apply_immediately                   = true
  deletion_protection                 = false
  iam_database_authentication_enabled = true
  tags = {
    Name = "${var.project_name}-rds"
  }
}

resource "aws_secretsmanager_secret" "rds_secret" {
  name = "${var.project_name}-db-secret"
}

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

resource "aws_ssm_parameter" "rds_endpoint" {
  name  = "/${var.project_name}/finance/rds"
  type  = "String"
  value = aws_db_instance.mysql.address
}

resource "aws_ssm_parameter" "rds_database" {
  name  = "/${var.project_name}/finance/rds_database"
  type  = "String"
  value = aws_db_instance.mysql.db_name
}

resource "aws_ssm_parameter" "rds_username" {
  name  = "/${var.project_name}/finance/rds_username"
  type  = "String"
  value = var.db_username
}
