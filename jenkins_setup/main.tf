terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
  }
  // This is the required version of Terraform
  required_version = "~> 1.2.7"
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon-2" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  #  owners = ["099720109477"]
  owners = ["amazon"]
}


resource "aws_instance" "master" {

  ami = data.aws_ami.amazon-2.id
  count                  = var.settings.web_app.count
  instance_type          = var.settings.web_app.instance_type
  subnet_id              = aws_subnet.master_public_subnet[count.index].id
  key_name               = aws_key_pair.master_kp.key_name
  vpc_security_group_ids = [aws_security_group.master_web_sg.id]

  tags = {
    Name = "master"
  }

}
resource "aws_key_pair" "master_kp" {
  key_name   = "master_kp"
  public_key = "${file("~/.ssh/master_kp.pub")}"
}

resource "aws_eip" "master_web_eip" {
  count    = var.settings.web_app.count
  instance = aws_instance.master[count.index].id
  vpc      = true

  tags = {
    Name = "master${count.index}"
  }
}