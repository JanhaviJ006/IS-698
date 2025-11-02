terraform {
  backend "s3" {
    bucket         = "terraform-state-janhavi-2025"   # <-- your bucket name
    key            = "terraform/state.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. VPC
resource "aws_vpc" "lab_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "lab7-vpc"
  }
}

# 2. Internet Gateway
resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "lab7-igw"
  }
}

# 3. Public Subnet
resource "aws_subnet" "lab_public_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "lab7-public-subnet"
  }
}

# 4. Route table for public subnet
resource "aws_route_table" "lab_public_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_igw.id
  }

  tags = {
    Name = "lab7-public-rt"
  }
}

resource "aws_route_table_association" "lab_public_assoc" {
  subnet_id      = aws_subnet.lab_public_subnet.id
  route_table_id = aws_route_table.lab_public_rt.id
}

# 5. Security group to allow SSH + HTTP (optional)
resource "aws_security_group" "lab_sg" {
  name        = "lab7-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.lab_vpc.id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lab7-sg"
  }
}

# 6. EC2 instance inside the VPC/subnet above
resource "aws_instance" "example" {
  ami                    = "ami-0c101f26f147fa7fd"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.lab_public_subnet.id
  vpc_security_group_ids = [aws_security_group.lab_sg.id]

  tags = {
    Name = "terraform-test-instance-janhavi"
  }
}
