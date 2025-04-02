# VPC 생성
resource "aws_vpc" "myvpc" {
  cidr_block = "20.40.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "MyVPC"
  }
}

# Public Subnet 생성
resource "aws_subnet" "mypublic_sub" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "20.40.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "My-Public-SN"
  }
}

# Internet Gateway 생성
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "My-IGW"
  }
}

# Public Route Table 생성
resource "aws_route_table" "mypublic_rt" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "MyPublicRT"
  }
}

# Public Route Table에 인터넷 게이트웨이 연결
resource "aws_route" "mypublic_igw" {
  route_table_id         = aws_route_table.mypublic_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Public Subnet에 Public Route Table 연결
resource "aws_route_table_association" "mypublic_rt_assoc" {
  subnet_id      = aws_subnet.mypublic_sub.id
  route_table_id = aws_route_table.mypublic_rt.id
}

# Security Group for Public Subnet
resource "aws_security_group" "mypublic_sg" {
  vpc_id = aws_vpc.myvpc.id
  name   = "MySG"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
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
resource "aws_network_acl" "mypublic_acl" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "public-acl"
  }
}

# NACL 규칙 추가 (Public Subnet용)
resource "aws_network_acl_rule" "mypublic_acl_allow_inbound" {
  network_acl_id = aws_network_acl.mypublic_acl.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "mypublic_acl_allow_outbound" {
  network_acl_id = aws_network_acl.mypublic_acl.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

# EC2 인스턴스 (Public Subnet)
resource "aws_instance" "mypublic_ec2" {
  ami           = "ami-070e986143a3041b6"  # 예시로 Amazon Linux 2 AMI (리전마다 다를 수 있음)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.mypublic_sub.id
  vpc_security_group_ids = [aws_security_group.mypublic_sg.id]
  key_name = "mykey"  # key pair 이름 지정
  associate_public_ip_address = true
  tags = {
    Name = "MyEC2"
  }
}

