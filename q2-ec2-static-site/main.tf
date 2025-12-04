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

variable "name_prefix"      { default = "Dhruv_Kumar_" }
variable "vpc_id"           {}
variable "public_subnet_id" {}

resource "aws_security_group" "web_sg" {
  name        = "${var.name_prefix}web_sg"
  description = "Allow HTTP and SSH"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "${var.name_prefix}web_sg"
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
  resume_html = <<-EOT
  <html>
  <head>
    <title>Dhruv Kumar - Resume</title>
    <style>
      body { font-family: Arial, sans-serif; max-width: 800px; margin: 40px auto; }
      h1 { margin-bottom: 0; }
      h3 { margin-top: 30px; }
      .subtitle { color: #555; margin-top: 5px; }
      ul { line-height: 1.5; }
    </style>
  </head>
  <body>
    <h1>Dhruv Kumar</h1>
    <p class="subtitle">B.Tech IT | AWS & DevOps Enthusiast</p>

    <h3>Skills</h3>
    <ul>
      <li>AWS (EC2, VPC, IAM, ALB, Auto Scaling)</li>
      <li>Terraform, Linux, Git & GitHub</li>
      <li>Backend: Node.js / Express, REST APIs</li>
      <li>Programming: C++, Python</li>
    </ul>

    <h3>Projects</h3>
    <ul>
      <li><b>AI Interview Platform</b> – Built an AI-based mock interview system with multi-agent LLM workflows.</li>
      <li><b>Static Resume Site on AWS</b> – Deployed personal resume on EC2 using Nginx and Terraform.</li>
    </ul>

    <h3>Contact</h3>
    <p>Email: dhruvkumar04553@gmail.com</p>
  </body>
  </html>
  EOT
}
resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
    instance_type = "t4g.micro"

  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
  #!/bin/bash
  apt-get update -y
  apt-get install -y nginx
  cat > /var/www/html/index.html << 'HTML'
  ${local.resume_html}
  HTML
  systemctl enable nginx
  systemctl restart nginx
  EOF

  tags = {
    Name = "${var.name_prefix}resume_ec2"
  }
}

output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}
