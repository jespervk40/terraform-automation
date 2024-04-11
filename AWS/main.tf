

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block              = var.vpc_cidr_block
  enable_dns_support      = true
  enable_dns_hostnames    = true
  assign_generated_ipv6_cidr_block = false
  tags = {
    Name = "MyVPC"
  }
}

# Create Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.subnet_cidr_block
  availability_zone       = var.availability_zone
  tags = {
    Name = "MySubnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create Route Table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "MyRouteTable"
  }
}

# Associate Subnet with Route Table
resource "aws_route_table_association" "my_subnet_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}


# creating security group
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id = aws_vpc.my_vpc.id
  dynamic "ingress" {
    for_each = var.ports
    iterator = port
    content {
      description = "TLS from VPC"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


# creating instance.
resource "aws_instance" "vkcorp" {
  ami                    = var.image_id
  instance_type          = var.instance_type
  key_name               = "ap-south-1"
  subnet_id = "${aws_subnet.my_subnet.id}"
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  tags = {
    Name = "vkcorp-instance"
  }
  # user_data = file("${path.module}/script.sh")
}
