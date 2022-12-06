terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
  }

  required_version = "~> 1.2.7"
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = "true"

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_db_instance" "jenkins_database" {
  allocated_storage      = var.settings.database.allocated_storage
  engine                 = var.settings.database.engine
  engine_version         = var.settings.database.engine_version
  instance_class         = var.settings.database.instance_class
  db_name                = var.settings.database.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.jenkins_db_subnet_group.id
  vpc_security_group_ids = [aws_security_group.jenkins_db_sg.id]
  skip_final_snapshot    = var.settings.database.skip_final_snapshot
}

resource "aws_key_pair" "tutorial_kp" {
  key_name   = "tutorial_kp_new"
  public_key = file("~/.ssh/tutorial_kp_new.pub")
}

resource "aws_instance" "jenkins_web" {
  count                  = var.settings.web_app.count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.settings.web_app.instance_type
  subnet_id              = aws_subnet.jenkins_public_subnet[count.index].id
  key_name               = aws_key_pair.tutorial_kp.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_web_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "jenkins_web_${count.index}"
  }
}

resource "aws_eip" "jenkins_web_eip" {
  count    = var.settings.web_app.count
  instance = aws_instance.jenkins_web[count.index].id
  vpc      = true

  tags = {
    Name = "jenkins_web_eip_${count.index}"
  }
}

resource "aws_lb_target_group" "jenkins_test" {
  name        = "tf-jenkins-test-lb-tg"
  port        = 8080
  target_type = "instance"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.jenkins_vpc.id
}

resource "aws_lb_target_group_attachment" "jattachmentgrp1" {
  target_group_arn = aws_lb_target_group.jenkins_test.arn
  target_id        = aws_instance.jenkins_web[0].id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "jattachmentgrp2" {
  target_group_arn = aws_lb_target_group.jenkins_test.arn
  target_id        = aws_instance.jenkins_web[1].id
  port             = 8080
}

resource "aws_lb" "jenkins_alb" {
  internal                         = false
  load_balancer_type               = "application"
  subnets                          = [for subnet in aws_subnet.jenkins_public_subnet : subnet.id]
  security_groups                  = [aws_security_group.jenkins_web_sg.id]
  enable_cross_zone_load_balancing = true

  tags = {
    Environment = "production"
    Name        = "jenkins_alb"
  }
}

resource "aws_lb_listener" "lb_jenkins_listener_http" {
  load_balancer_arn = aws_lb.jenkins_alb.id
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.jenkins_test.id
    type = "forward"
  }
}