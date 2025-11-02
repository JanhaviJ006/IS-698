# part2/main.tf

provider "aws" {
  region = "us-east-1"
}

# 1) VPC
resource "aws_vpc" "lab_vpc" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "loops2-vpc"
  }
}

# 2) Internet Gateway
resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "loops2-igw"
  }
}

# 3) Public Subnet
resource "aws_subnet" "lab_public" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.20.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "loops2-public-subnet"
  }
}

# 4) Route table for public subnet
resource "aws_route_table" "lab_public_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_igw.id
  }

  tags = {
    Name = "loops2-public-rt"
  }
}

resource "aws_route_table_association" "lab_public_assoc" {
  subnet_id      = aws_subnet.lab_public.id
  route_table_id = aws_route_table.lab_public_rt.id
}

# 5) Security group
resource "aws_security_group" "lab_sg" {
  name        = "loops2-sg"
  description = "allow ssh and http"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http"
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
    Name = "loops2-sg"
  }
}

# 6) Define different instances (this is the for_each part of the lab)
variable "instances" {
  type = map(string)
  default = {
    web1 = "t3.micro"
    web2 = "t3.micro"
    web3 = "t3.small"
  }
}

# 7) EC2 instances using for_each
resource "aws_instance" "web" {
  for_each = var.instances

  ami                    = "ami-0c101f26f147fa7fd"
  instance_type          = each.value
  subnet_id              = aws_subnet.lab_public.id
  vpc_security_group_ids = [aws_security_group.lab_sg.id]

  tags = {
    Name = each.key
  }
}
