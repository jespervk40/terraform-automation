# Define provider
provider "aws" {
  region = "us-west-2"  # Change to your desired region
}

# Create VPC
resource "aws_vpc" "my_tf_vpc" {
  cidr_block = "10.0.0.0/16"  # Adjust CIDR block as needed
}

# Create subnets
resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_tf_vpc.id
  cidr_block        = "10.0.1.0/24"  # Adjust CIDR block as needed
  availability_zone = "us-west-2a"  # Change to your desired AZ
}

# Add internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_tf_vpc.id
}

# Configure route table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_tf_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Implement security rules
resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_tf_vpc.id

  // Define inbound and outbound rules as needed
  // Example:
  ingress {
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
}
