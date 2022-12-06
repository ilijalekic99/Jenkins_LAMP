resource "aws_vpc" "jenkins_vpc" {

  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "jenkins_vpc"
  }
}

resource "aws_internet_gateway" "jenkins_igw" {
  vpc_id = aws_vpc.jenkins_vpc.id

  tags = {
    Name = "jenkins_igw"
  }
}

resource "aws_subnet" "jenkins_public_subnet" {
  count             = var.subnet_count.public
  vpc_id            = aws_vpc.jenkins_vpc.id
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "jenkins_public_subnet_${count.index}"
  }
}

resource "aws_subnet" "jenkins_private_subnet" {
  count             = var.subnet_count.private
  vpc_id            = aws_vpc.jenkins_vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "jenkins_private_subnet_${count.index}"
  }
}

resource "aws_route" "jenkins_public_route" {
  depends_on             = [aws_internet_gateway.jenkins_igw]
  route_table_id         = aws_route_table.jenkins_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.jenkins_igw.id
}

resource "aws_route_table" "jenkins_public_rt" {
  vpc_id = aws_vpc.jenkins_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins_igw.id
  }
}

resource "aws_route_table_association" "jenkins_public" {
  count          = var.subnet_count.public
  route_table_id = aws_route_table.jenkins_public_rt.id
  subnet_id      = 	aws_subnet.jenkins_public_subnet[count.index].id
}

resource "aws_route_table" "jenkins_private_rt" {
  vpc_id = aws_vpc.jenkins_vpc.id
}

resource "aws_route_table_association" "jenkins_private" {
  count          = var.subnet_count.private
  route_table_id = aws_route_table.jenkins_private_rt.id
  subnet_id      = aws_subnet.jenkins_private_subnet[count.index].id
}

resource "aws_db_subnet_group" "jenkins_db_subnet_group" {
  name        = "jenkins_db_subnet_group"
  description = "DB subnet group for jenkins"
  subnet_ids  = [for subnet in aws_subnet.jenkins_private_subnet : subnet.id]
}