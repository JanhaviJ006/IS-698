
# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-janhavi-2025"
#     key            = "loops/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-lock"
#     encrypt        = true
#   }
# }

provider "aws" {
  region = "us-east-1"
}

# 1) VPC
resource "aws_vpc" "lab_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "loops-vpc"
  }
}

# 2) IGW
resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "loops-igw"
  }
}

# 3) Public subnet
resource "aws_subnet" "lab_public" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "loops-public-subnet"
  }
}

# 4) Route table
resource "aws_route_table" "lab_public_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_igw.id
  }

  tags = {
    Name = "loops-public-rt"
  }
}

resource "aws_route_table_association" "lab_public_assoc" {
  subnet_id      = aws_subnet.lab_public.id
  route_table_id = aws_route_table.lab_public_rt.id
}

# 5) Security group
resource "aws_security_group" "lab_sg" {
  name        = "loops-sg"
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
    Name = "loops-sg"
  }
}

# 6) EC2s using COUNT
resource "aws_instance" "web" {
  count = 3  # <- this is the loop

  ami                    = "ami-0c101f26f147fa7fd" # us-east-1
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.lab_public.id
  vpc_security_group_ids = [aws_security_group.lab_sg.id]

  tags = {
    Name = "Terraform-Instance-${count.index}"
  }
}
