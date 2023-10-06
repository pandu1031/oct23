# Define your provider (AWS in this case)
provider "aws" {
  region = "us-east-1" # Change this to your desired AWS region
}
# Create an Bastion EC2 instance in the VPC and subnet
resource "aws_instance" "example-0" {
  ami             = "ami-00c6177f250e07ec1" # Replace with your desired AMI ID
  instance_type   = "t2.micro"              # Replace with your desired instance type
  subnet_id       = aws_subnet.public1a.id
  key_name        = "devops23"                      # Replace with your SSH key pair name
  security_groups = [aws_security_group.example.id] # Replace with your security group name(s) if needed
  tags = {
    Name = "stage-gateway"
  }
}
# Create an jenkins EC2 instance in the VPC and subnet
resource "aws_instance" "example-1" {
  ami             = "ami-00c6177f250e07ec1" # Replace with your desired AMI ID
  instance_type   = "t2.micro"              # Replace with your desired instance type
  subnet_id       = aws_subnet.public1a.id
  key_name        = "devops23"                      # Replace with your SSH key pair name
  security_groups = [aws_security_group.example.id] # Replace with your security group name(s) if needed
  tags = {
    Name = "jenkins-master"
  }
}
# Create an slavenode EC2 instance in the VPC and subnet
resource "aws_instance" "example-2" {
  ami             = "ami-00c6177f250e07ec1" # Replace with your desired AMI ID
  instance_type   = "t2.micro"              # Replace with your desired instance type
  subnet_id       = aws_subnet.private1a.id
  key_name        = "devops23"                      # Replace with your SSH key pair name
  security_groups = [aws_security_group.example.id] # Replace with your security group name(s) if needed
  tags = {
    Name = "slave-node"
  }
}
# Create an tomcat EC2 instance in the VPC and subnet
resource "aws_instance" "example-3" {
  ami             = "ami-00c6177f250e07ec1" # Replace with your desired AMI ID
  instance_type   = "t2.micro"              # Replace with your desired instance type
  subnet_id       = aws_subnet.private1a.id
  key_name        = "devops23"                      # Replace with your SSH key pair name
  security_groups = [aws_security_group.example.id] # Replace with your security group name(s) if needed
  tags = {
    Name = "tomcat"
  }
}

# Create a security group
resource "aws_security_group" "example" {
  name        = "my-security-group"
  description = "My security group for EC2 instances"
  vpc_id      = aws_vpc.example.id

  # Inbound rule allowing SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # This allows SSH access from any IP address (be cautious in a production environment)
  }

  # Inbound rule allowing HTTP access from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # This allows HTTP access from any IP address (be cautious in a production environment)
  }
   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # This allows HTTP access from any IP address (be cautious in a production environment)
  }

  # You can add more ingress rules as needed
  

  # Outbound rule allowing all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a VPC
resource "aws_vpc" "example" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
  }
}

# Create an internet gateway to allow traffic in and out of the VPC
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
  tags = {
    Name = "my-igw"
  }
}

# Create a public subnet
resource "aws_subnet" "public1a" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.23.0/24" # Change this to your desired public subnet CIDR block
  availability_zone       = "us-east-1a"   # Change this to your desired availability zone
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1a"
  }
}

# Create a private subnet
resource "aws_subnet" "private1a" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.34.0/24" # Change this to your desired private subnet CIDR block
  availability_zone = "us-east-1a"   # Change this to your desired availability zone
  tags = {
    Name = "private-subnet-1a"
  }
}

resource "aws_subnet" "public1b" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.5.0/24" # Change this to your desired public subnet CIDR block
  availability_zone       = "us-east-1b"  # Change this to your desired availability zone
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1b"
  }
}
# Create a private subnet
resource "aws_subnet" "private1b" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.8.0/24" # Change this to your desired private subnet CIDR block
  availability_zone = "us-east-1b"  # Change this to your desired availability zone
  tags = {
    Name = "private-subnet-1b"
  }
}
# Create a route table for the public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }

  tags = {
    Name = "public-route-table-1"
  }
}

# Create a route table for the private subnet
resource "aws_route_table" "private-rt-1a" {
  vpc_id = aws_vpc.example.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.example-1.id
  }
  tags = {
    Name = "private-route-table-1"
  }
}
# Create a route table for the private subnet
resource "aws_route_table" "private-rt-1b" {
  vpc_id = aws_vpc.example.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.example-2.id
  }
  tags = {
    Name = "private-route-table-2"
  }
}


# Create a NAT gateway
resource "aws_nat_gateway" "example-1" {
  allocation_id = aws_eip.example-1.id
  subnet_id     = aws_subnet.public1a.id

  tags = {
    Name = "my-nat-gateway-1a"
  }
}

# Create a NAT gateway
resource "aws_nat_gateway" "example-2" {
  allocation_id = aws_eip.example-2.id
  subnet_id     = aws_subnet.public1b.id

  tags = {
    Name = "my-nat-gateway-1b"
  }
}


# Create an Elastic IP for the NAT gateway
resource "aws_eip" "example-1" {}
# Create an Elastic IP for the NAT gateway
resource "aws_eip" "example-2" {}

# Associate the private subnet with the private route table
resource "aws_route_table_association" "private-1a" {
  subnet_id      = aws_subnet.private1a.id
  route_table_id = aws_route_table.private-rt-1a.id
}
# Associate the private subnet with the private route table
resource "aws_route_table_association" "private-1b" {
  subnet_id      = aws_subnet.private1b.id
  route_table_id = aws_route_table.private-rt-1b.id
}
# Associate the public subnet with the public route table
resource "aws_route_table_association" "public-1a" {
  subnet_id      = aws_subnet.public1a.id
  route_table_id = aws_route_table.public.id
}
# Associate the public subnet with the public route table
resource "aws_route_table_association" "public-1b" {
  subnet_id      = aws_subnet.public1b.id
  route_table_id = aws_route_table.public.id
}
resource "aws_lb" "example_lb" {
  name               = "example-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public1a.id, aws_subnet.public1b.id] # Replace with your subnet IDs
  security_groups    = [aws_security_group.example.id]
}
resource "aws_lb_target_group" "example_target_group" {
  name     = "example-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.example.id
}

resource "aws_lb_target_group_attachment" "example_attachment" {
  target_group_arn = aws_lb_target_group.example_target_group.arn
  target_id        = aws_instance.example-3.id
  port             = 80
}

resource "aws_lb_listener" "example_listener" {
  load_balancer_arn = aws_lb.example_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
    }
  }
}
resource "aws_lb_listener_rule" "example_rule" {
  listener_arn = aws_lb_listener.example_listener.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example_target_group.arn
  }
  condition {
    path_pattern {
      values = ["/example"]
    }
  }
}

resource "aws_lb_target_group_attachment" "example_1_attachment" {
  target_group_arn  = aws_lb_target_group.example_target_group.arn
  target_id         = aws_instance.example-3.id  # Replace with your instance ID or other target
  port              = 8080  # Make sure it matches the target group's port
}
# Output the VPC ID
output "vpc_id" {
  value = aws_vpc.example.id
}
