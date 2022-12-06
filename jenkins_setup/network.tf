resource "aws_vpc" "master_vpc" {

  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "master_vpc"
  }
}

resource "aws_internet_gateway" "master_igw" {
  vpc_id = aws_vpc.master_vpc.id

  tags = {
    Name = "master_igw"
  }
}

resource "aws_subnet" "master_public_subnet" {
  count             = var.subnet_count.public
  vpc_id            = aws_vpc.master_vpc.id
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "master_public_subnet_${count.index}"
  }
}

resource "aws_subnet" "master_private_subnet" {
  count             = var.subnet_count.private
  vpc_id            = aws_vpc.master_vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "master_private_subnet_${count.index}"
  }
}

resource "aws_route_table" "master_public_rt" {
  vpc_id = aws_vpc.master_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.master_igw.id
  }
}

resource "aws_route_table_association" "public_rta" {
  count          = var.subnet_count.public
  route_table_id = aws_route_table.master_public_rt.id
  subnet_id      = 	aws_subnet.master_public_subnet[count.index].id
}

resource "aws_route_table" "master_private_rt" {
  vpc_id = aws_vpc.master_vpc.id
}

resource "aws_route_table_association" "private" {
  count          = var.subnet_count.private
  route_table_id = aws_route_table.master_private_rt.id
  subnet_id      = aws_subnet.master_private_subnet[count.index].id
}

resource "aws_route" "public" {
  depends_on             = [aws_internet_gateway.master_igw]
  route_table_id         = aws_route_table.master_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.master_igw.id
}