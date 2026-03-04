# resource "aws_instance" "host" {
#     ami = "ami-0b6c6ebed2801a5cb"
#     instance_type = "t3.micro"
#     tags = {
#       project = "deployment"
#     }
# }


resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  region = "us-east-1"

  tags = {
    Name = "Main"
  }
}

resource "aws_subnet" "main_public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}


resource "aws_subnet" "main_private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Main"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main"
  }
}

resource "aws_route" "r1" {
  route_table_id            = aws_route_table.public_route.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main_public.id
  route_table_id = aws_route_table.public_route.id
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "demo_instance_public" {
  subnet_id     = aws_subnet.main_public.id
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  region = "us-east-1"
  associate_public_ip_address = true


  tags = {
    Name = "Main"
  }
}
resource "aws_instance" "demo_instance_private" {
  subnet_id     = aws_subnet.main_private.id
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  tags = {
    Name = "Main"
  }
}