resource "aws_security_group" "master_web_sg" {
  name        = "tutorial_web_sg"
  description = "Security group for tutorial web servers"
  vpc_id      = aws_vpc.master_vpc.id

  ingress {
    description = "Allow all traffic through HTTP"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH from my computer"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    // This is using the variable "my_ip"
    cidr_blocks = ["${var.my_ip}/0"]
  }

  ingress {
    description = "Allow jen_in"
    from_port   = "8080"
    to_port     = "8080"
    protocol    = "tcp"
    // This is using the variable "my_ip"
    cidr_blocks = ["${var.my_ip}/0"]
  }

  ingress {
    description = "Allow SSH from my computer"
    from_port   = "50000"
    to_port     = "50000"
    protocol    = "tcp"
    // This is using the variable "my_ip"
    cidr_blocks = ["${var.my_ip}/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "master_sg"
  }
}