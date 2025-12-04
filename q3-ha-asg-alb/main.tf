terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

variable "name_prefix"        { default = "Dhruv_Kumar_" }
variable "vpc_id"             {}
variable "public_subnet_ids"  { type = list(string) }
variable "private_subnet_ids" { type = list(string) }

resource "aws_security_group" "alb_sg" {
  name   = "${var.name_prefix}alb_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}alb_sg"
  }
}

resource "aws_security_group" "app_sg" {
  name   = "${var.name_prefix}app_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
    description     = "HTTP from ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}app_sg"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-arm64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

locals {
  app_html = <<-EOT
  <html>
  <head><title>Dhruv Kumar - HA App</title></head>
  <body>
    <h1>Highly Available Web App</h1>
    <p>Served via Auto Scaling Group behind an ALB.</p>
  </body>
  </html>
  EOT
}

resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.name_prefix}app_lt"
  image_id      = data.aws_ami.ubuntu.id
    instance_type = "t4g.micro"


  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(<<-EOF
  #!/bin/bash
  apt-get update -y
  apt-get install -y nginx
  cat > /var/www/html/index.html << 'HTML'
  ${local.app_html}
  HTML
  systemctl enable nginx
  systemctl restart nginx
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.name_prefix}ha_app"
    }
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "dhruv-ha-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path              = "/"
    matcher           = "200"
    interval          = 30
    healthy_threshold = 3
  }

  tags = {
    Name = "${var.name_prefix}tg"
  }
}

resource "aws_lb" "alb" {
  name               = "dhruv-ha-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${var.name_prefix}alb"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = "${var.name_prefix}asg"
  max_size            = 4
  min_size            = 2
  desired_capacity    = 2
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]

  health_check_type         = "EC2"
  health_check_grace_period = 60

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}asg_instance"
    propagate_at_launch = true
  }
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}
