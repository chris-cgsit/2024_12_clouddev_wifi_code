
lifecycle {
   prevent_destroy = true
}


# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name  = "${var.trainee_name}-vpc"
    Owner = var.trainee_name
  }
}

# Public Subnet (DMZ)
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidrs["public"]
  map_public_ip_on_launch = true

  tags = {
    Name  = "${var.trainee_name}-public-subnet"
    Owner = var.trainee_name
  }
}

# Application Subnet
resource "aws_subnet" "app" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidrs["app"]

  tags = {
    Name  = "${var.trainee_name}-app-subnet"
    Owner = var.trainee_name
  }
}

# Database Subnet
resource "aws_subnet" "db" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidrs["db"]

  tags = {
    Name  = "${var.trainee_name}-db-subnet"
    Owner = var.trainee_name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name  = "${var.trainee_name}-igw"
    Owner = var.trainee_name
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name  = "${var.trainee_name}-public-rt"
    Owner = var.trainee_name
  }
}

# Associate Public Subnet with Route Table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Groups
## Public (DMZ) Security Group
resource "aws_security_group" "public" {
  name   = "${var.trainee_name}-public-sg"  
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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

  tags = {
    Name  = "${var.trainee_name}-public-sg"
    Owner = var.trainee_name
  }
}

## Application Security Group
resource "aws_security_group" "app" {
  name   = "${var.trainee_name}-app-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.trainee_name}-app-sg"
    Owner = var.trainee_name
  }
}

## Database Security Group
resource "aws_security_group" "db" {
  name   = "${var.trainee_name}-db-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.app.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.trainee_name}-db-sg"
    Owner = var.trainee_name
  }
}

# Instances
## Web Server Instance
resource "aws_instance" "web" {
  ami           = "ami-0a628e1e89aaedf80" # Ubuntu AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  key_name      = "${var.trainee_name}_key" # Replace with a valid key pair

  # Use security_group_ids instead of security_groups
#   security_group_ids = [aws_security_group.public.id]
#  security_groups = [aws_security_group.public.name]
  vpc_security_group_ids = [aws_security_group.public.id] 

  tags = {
    Name  = "${var.trainee_name}-web-server"
    Owner = var.trainee_name
  }
}

## Application Server Instance
resource "aws_instance" "app" {
  ami           = "ami-0a628e1e89aaedf80" # Ubuntu AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.app.id
#  key_name      = "${var.trainee_name}-key" # Replace with a valid key pair train-002_key
  key_name      = "${var.trainee_name}_key" # Replace with a valid key pair train-002_key

  # Use security_group_ids instead of security_groups
#  security_group_ids = [aws_security_group.app.id]
#  security_groups = [aws_security_group.app.name]
  vpc_security_group_ids = [aws_security_group.app.id] 

  tags = {
    Name  = "${var.trainee_name}-app-server"
    Owner = var.trainee_name
  }
}

## Database Server Instance
resource "aws_instance" "db" {
  ami           = "ami-0a628e1e89aaedf80" # Ubuntu AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.db.id
#  key_name      = "trainee-key" # Replace with a valid key pair
  key_name      = "${var.trainee_name}_key" # Replace with a valid key pair train-002_key

  # Use security_group_ids instead of security_groups
#  security_group_ids = [aws_security_group.db.id]
#  security_groups = [aws_security_group.db.name]
  vpc_security_group_ids = [aws_security_group.db.id] 

  tags = {
    Name  = "${var.trainee_name}-db-server"
    Owner = var.trainee_name
  }
}






