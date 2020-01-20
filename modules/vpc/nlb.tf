resource "aws_eip" "eip_nlb" {
  tags = {
    Name = "${var.env}+eip_nlb"
  }
}


resource "aws_lb" "front-end-lb" {
  name                       = "${var.env}-lb"
  internal                   = false
  load_balancer_type         = "network"
  #subnets                    = [var.public_subnet]
  #subnet_mapping {
  #  subnet_id = [var.public_subnet]
  #  allocation_id = aws_eip.eip_nlb.id
 # }
  enable_deletion_protection = true
  tags = {
    Environment = var.env
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.front-end-lb.arn
  port = 80
  protocol = "TCP"
  default_action {
    target_group_arn = aws_lb_target_group.web-nlb-tg.arn
    type = "forward"
  }
}

resource "aws_lb_target_group" "web-nlb-tg" {
  name = "web-nlb-tg"
  port = 80
  protocol = "tcp"
  vpc_id = aws_vpc.vpc.id
  target_type = "instance"
  health_check {
    interval = 60
    port = "80"
    protocol = "TCP"
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "tga" {
  target_group_arn = aws_lb_target_group.web-nlb-tg.arn
  port = 80
  target_id = [var.web-instance-id]
}