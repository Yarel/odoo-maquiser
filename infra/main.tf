provider "aws" {
  region = var.aws_region
}

# resource "aws_key_pair" "maquiser_key" {
#   key_name   = var.key_name
#   public_key = file(var.public_key_path)
# }

resource "aws_vpc" "maquiser_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.maquiser_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.maquiser_vpc.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.maquiser_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "maquiser_sg" {
  name        = "maquiser_sg"
  description = "Allow SSH, HTTP, HTTPS"
  vpc_id      = aws_vpc.maquiser_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "odoo" {
  ami                         = "ami-053b0d53c279acc90" # Ubuntu 22.04 us-east-1
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.maquiser_sg.id]
  associate_public_ip_address = true

  user_data = file("user_data.sh")

  tags = {
    Name = "Odoo-Maquiser"
  }
}

