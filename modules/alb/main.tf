resource "aws_lb" "main-lb" {
  name                             = "${var.projectname}-alb"
  internal                         = false
  load_balancer_type               = var.load_balancer_type
  security_groups                  = var.security_groups
  subnets                          = var.subnet_ids
  enable_cross_zone_load_balancing = true
  drop_invalid_header_fields       = true
  # enable_deletion_protection = true

  access_logs {
    bucket  = var.log_bucket
    enabled = true
    prefix  = "alb-logs"
  }

  tags = {
    Name        = "${var.projectname}-alb"
    Environment = var.environment
  }
}

# Single Target Group for Both HTTP & HTTPS
resource "aws_lb_target_group" "main" {
  name     = "${var.projectname}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = "/health.php"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
    matcher             = "200-299"
  }
}

# HTTP Listener (Redirect to HTTPS)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener with ACM Certificate
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}