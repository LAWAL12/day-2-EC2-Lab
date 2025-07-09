provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "main_vpc" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
    vpc_id      = aws_vpc.main_vpc.id
    cidr_block  = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true

    tags = {
      Name = "publicsubnet"
    }
}
resource "aws_internet_gateway" "main_igw" {
    vpc_id = aws_vpc.main_vpc.id

    tags = {
        Name = "mainIGW"
    }
}
resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.main_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main_igw.id
    }
    tags = {
        Name = "publicroutetable"
    }
}
resource "aws_route_table_association" "public_route_table_association" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_route_table.id
}
resource "tls_private_key" "key" {
    algorithm = "RSA"
    rsa_bits = 4096
}
resource "aws_key_pair" "developer_key" {
    key_name = "developer_key"
    public_key = tls_private_key.key.public_key_openssh
}
resource "aws_security_group" "ssh_SG" {
    name = "ssh_SG_access"
    vpc_id = aws_vpc.main_vpc.id
    description = "Allow SSH access"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = { 
        Name = "ssh_SG_access"
    }
}
resource "aws_instance" "web" {
    ami = "ami-0c02fb55956c7d316"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public_subnet.id
    vpc_security_group_ids = [aws_security_group.ssh_SG.id]
    associate_public_ip_address = true
    key_name = aws_key_pair.developer_key.key_name

    tags = {
        Name = "EC2_day_2"
    }
}