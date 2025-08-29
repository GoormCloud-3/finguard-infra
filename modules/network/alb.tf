resource "aws_lb" "alb" {
  name               = "${var.project_name}-${var.env}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  #   subnets            = [for subnet in aws_subnet.alb_subnets : subnet.id]
  subnets                    = values(aws_subnet.alb_subnets)[*].id
  enable_deletion_protection = false
  idle_timeout               = 60

  tags = {
    Name = "${var.project_name}-${var.env}-alb"
  }
}

resource "aws_lb_target_group" "account" {
  name        = "${var.project_name}-${var.env}-account-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    protocol            = "HTTP"
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.project_name}-${var.env}-account-tg"
  }
}

resource "aws_lb_target_group" "transaction" {
  name        = "${var.project_name}-${var.env}-transaction-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    protocol            = "HTTP"
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.project_name}-${var.env}-transaction-tg"
  }
}

resource "aws_lb_target_group" "user" {
  name        = "${var.project_name}-${var.env}-user-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    protocol            = "HTTP"
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.project_name}-${var.env}-user-tg"
  }
}


resource "aws_lb_listener" "http_80" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

# /accounts/*
resource "aws_lb_listener_rule" "rule_accounts" {
  listener_arn = aws_lb_listener.http_80.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.account.arn
  }

  condition {
    path_pattern {
      values = ["/accounts/*"]
    }
  }
}

# /transaction, /transaction/*
resource "aws_lb_listener_rule" "rule_transaction" {
  listener_arn = aws_lb_listener.http_80.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.transaction.arn
  }

  condition {
    path_pattern { values = ["/transaction", "/transaction/*"] }
  }
}

# /users, /users/*
resource "aws_lb_listener_rule" "rule_users" {
  listener_arn = aws_lb_listener.http_80.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.user.arn
  }

  condition {
    path_pattern { values = ["/users", "/users/*"] }
  }
}