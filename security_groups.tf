# RDS Proxy 접근을 하는 람다가 사용할 보안 그룹
resource "aws_security_group" "dao" {
  name = "${var.project_name}-dao"
  description = "Security group which can do access to ${var.project_name}-mysql database"
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}-rds-dao"
  }
}

# RDS Proxy SG
resource "aws_security_group" "rds_proxy" {
  name        = "${var.project_name}-rds-proxy"
  description = "Allow Lambda to access RDS Proxy"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port                = 3306
    to_port                  = 3306
    protocol                 = "tcp"
    security_groups          = [aws_security_group.dao.id] # Lambda 보안그룹의 접근을 허용
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Proxy → RDS로 나가야 하므로 허용
  }

  tags = {
    Name = "${var.project_name}-rds-proxy"
  }
}

# RDS의 보안그룹으로 Proxy를 통한 접근만 허용
resource "aws_security_group" "mysql" {
  name        = "${var.project_name}-rds"
  description = "Allow MySQL inbound traffic (adjust CIDR for production)"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.rds_proxy.id]
  }

  tags = {
    Name = "${var.project_name}-rds"
  }
}