resource "aws_db_subnet_group" "mysql" {
  name       = "mysql-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]
  tags = {
    Name = "${var.project_name}-rds"
  }
}

resource "aws_db_instance" "mysql" {
  identifier             = "${var.project_name}-rds"
  db_name = "${var.project_name}"
  engine                 = "mysql"
  engine_version         = "8.0.36"
  instance_class         = "db.t4g.micro"
  allocated_storage      = 20
  storage_type           = "gp3"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.mysql.name
  vpc_security_group_ids = [aws_security_group.mysql.id]
  publicly_accessible    = false
  multi_az               = true
  skip_final_snapshot    = true
  apply_immediately      = true
  deletion_protection    = false
  iam_database_authentication_enabled = true
  tags = {
    Name = "${var.project_name}-rds"
  }
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