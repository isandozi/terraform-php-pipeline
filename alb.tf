resource "aws_lb" "modetrans_alb" {
  name                       = "${var.application_name}-${terraform.workspace}"
  subnets                    = local.public_subnet_ids
  enable_deletion_protection = false

  security_groups = [
    aws_security_group.modetrans_alb_sg.id
  ]

  timeouts {
    create = "60m"
  }

  tags = {
    Environment = var.application_environment[var.region]
  }
}

resource "aws_lb_listener" "modetrans_listener_forward" {
  load_balancer_arn = aws_lb.modetrans_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.modetrans_tg.arn
  }
}

resource "aws_lb_target_group" "modetrans_tg" {
  depends_on  = [aws_lb.modetrans_alb]
  name        = "${var.application_name}-${terraform.workspace}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.modetrans_vpc.id

  health_check {
    healthy_threshold   = "3"
    unhealthy_threshold = "3"
    matcher = "200"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = "14400"
  }
}

output "Load_Balancer_DNS_Name" {
  value = aws_lb.modetrans_alb.dns_name
}
