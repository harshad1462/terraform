#specifid provider
provider "aws" {
  region ="ap-south-1"
}
#vpc
resource "aws_vpc" "myvpc1" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name="myvpc1"
  }
}
#Subnet1
resource "aws_subnet" "sub1" {
  vpc_id     = aws_vpc.myvpc1.id
  cidr_block = "10.0.1.0/24"
  availability_zone ="ap-south-1a"
  tags = {
    Name = "sub1"
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.custom-rt.id
}
#Subnet2
resource "aws_subnet" "sub2" {
  vpc_id     = aws_vpc.myvpc1.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "sub2"
  }
}
#sub association
resource "aws_route_table_association" "b"{
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.custom-rt.id
}
#internet getway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc1.id

  tags = {
    Name = "gw"
  }
}
#route table
resource "aws_route_table" "custom-rt" {
  vpc_id = aws_vpc.myvpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "custom-rt"
  }
}
#security group
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc1.id

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"# to allaow connection from all the points
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
#aws instance
#
resource "aws_network_interface" "instance_nintreface"{
  subnet_id   = aws_subnet.sub2.id

  tags = {
    Name = "primary_network_interface"
  }
}
#t2 micro
resource "aws_instance" "web" {
  ami           = "ami-0fd05997b4dff7aac"
  instance_type = "t2.micro"
  key_name = "awskey"
  subnet_id = aws_subnet.sub2.id
  security_groups = [ aws_security_group.allow_ssh.id]
  tags = {
    Name = "HelloWorldInstance"
  }
}

