provider "aws" {
  region = "ap-south-1"
}
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

variable "subnets_cidr" {
  description = "Total number of subnets"
  type = map(string)
  default = {
    "ap-south-1a" = "10.0.1.0/24",
    "ap-south-1b" = "10.0.2.0/24",
    "ap-south-1c" = "10.0.3.0/24"

  }
}

resource "aws_subnet" "sub" {
  for_each = var.subnets_cidr
  vpc_id = aws_vpc.main.id
  cidr_block = each.value
  availability_zone = each.key
  tags = {
    Name = each.key
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "internet gateway"
  }
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "example"
  }
}

resource "aws_security_group" "security_gorup" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}