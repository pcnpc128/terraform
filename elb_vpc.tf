terraform {
  required_version = ">= 1.5.0"  # 최소 Terraform 버전 1.5.0 이상
}

provider "aws" { }

# VPC 생성
resource "aws_vpc" "elb_vpc" {
  cidr_block = "10.40.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "ELB-VPC"
  }
}

# Public Subnet 생성
resource "aws_subnet" "elb_public_sub1" {
  vpc_id                  = aws_vpc.elb_vpc.id
  cidr_block              = "10.40.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "ELBPublicSN1"
  }
}

resource "aws_subnet" "elb_public_sub2" {
  vpc_id                  = aws_vpc.elb_vpc.id
  cidr_block              = "10.40.2.0/24"
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = true
  tags = {
    Name = "ELBPublicSN2"
  }
}

# Internet Gateway 생성
resource "aws_internet_gateway" "elb_igw" {
  vpc_id = aws_vpc.elb_vpc.id
  tags = {
    Name = "ELB-IGW"
  }
}

# Public Route Table 생성
resource "aws_route_table" "elb_public_rt" {
  vpc_id = aws_vpc.elb_vpc.id
  tags = {
    Name = "ELBPublicRT"
  }
}

# Public Route Table에 인터넷 게이트웨이 연결
resource "aws_route" "elb_public_igw" {
  route_table_id         = aws_route_table.elb_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.elb_igw.id
}

# Public Subnet에 Public Route Table 연결
resource "aws_route_table_association" "elb_public_rt_assoc1" {
  subnet_id      = aws_subnet.elb_public_sub1.id
  route_table_id = aws_route_table.elb_public_rt.id
}

resource "aws_route_table_association" "elb_public_rt_assoc2" {
  subnet_id      = aws_subnet.elb_public_sub2.id
  route_table_id = aws_route_table.elb_public_rt.id
}

# Security Group for Public Subnet
resource "aws_security_group" "elb_public_sg" {
  vpc_id = aws_vpc.elb_vpc.id
  name   = "ELBSG"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  ingress {
    from_port   = 161
    to_port     = 161
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# NACL 생성 (Public Subnet용)
resource "aws_network_acl" "elb_public_acl" {
  vpc_id = aws_vpc.elb_vpc.id
  tags = {
    Name = "ELB-Public-acl"
  }
}

# NACL 규칙 추가 (Public Subnet용)
resource "aws_network_acl_rule" "elb_public_acl_allow_inbound" {
  network_acl_id = aws_network_acl.elb_public_acl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "elb_public_acl_allow_outbound" {
  network_acl_id = aws_network_acl.elb_public_acl.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

# EC2 인스턴스 (Public Subnet)
resource "aws_instance" "server1_ec2" {
  ami           = "ami-070e986143a3041b6"  # 예시로 Amazon Linux 2 AMI (리전마다 다를 수 있음)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.elb_public_sub1.id
  vpc_security_group_ids = [aws_security_group.elb_public_sg.id]
  key_name = "mykey"  # key pair 이름 지정
  associate_public_ip_address = true
  tags = {
    Name = "SERVER-1"
  }
}

resource "aws_instance" "server2_ec2" {
  ami           = "ami-070e986143a3041b6"  # 예시로 Amazon Linux 2 AMI (리전마다 다를 수 있음)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.elb_public_sub2.id
  vpc_security_group_ids = [aws_security_group.elb_public_sg.id]
  key_name = "mykey"  # key pair 이름 지정
  associate_public_ip_address = true
  tags = {
    Name = "SERVER-2"
  }
}

resource "aws_instance" "server3_ec2" {
  ami           = "ami-070e986143a3041b6"  # 예시로 Amazon Linux 2 AMI (리전마다 다를 수 있음)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.elb_public_sub2.id
  vpc_security_group_ids = [aws_security_group.elb_public_sg.id]
  key_name = "mykey"  # key pair 이름 지정
  associate_public_ip_address = true
  tags = {
    Name = "SERVER-3"
  }
}
