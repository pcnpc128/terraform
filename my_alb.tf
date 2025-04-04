# ALB 생성
resource "aws_lb" "alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.elb_public_sg.id]
  subnets           = [
    aws_subnet.elb_public_sub1.id,
    aws_subnet.elb_public_sub2.id
  ]
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "my-alb"
  }
}

# ALB Target Group 생성
resource "aws_lb_target_group" "alb_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.elb_vpc.id
  health_check {
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "my-target-group"
  }
}

# ALB Listener 생성
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      status_code = 200
      content_type = "text/plain"
      message_body = "Hello from ALB"
    }
  }
}

# EC2 인스턴스를 ALB Target Group에 등록
resource "aws_lb_target_group_attachment" "attachment_server1" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.server1_ec2.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attachment_server2" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.server2_ec2.id
  port             = 80
 }

resource "aws_lb_target_group_attachment" "attachment_server3" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.server3_ec2.id
  port             = 80
}
