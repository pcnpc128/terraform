resource "aws_security_group" "my_sg" {
	vpc_id	= aws_vpc.my_vpc.id

	egress {
		cidr_blocks = ["0.0.0.0/0"]
		from_port = 0
		to_port = 0
		protocol = "-1"
	}

        ingress {
                cidr_blocks = ["0.0.0.0/0"]
                from_port = 22
                to_port = 22
                protocol = "tcp"
	}

	ingress {
                cidr_blocks = ["0.0.0.0/0"]
                from_port = 80
                to_port = 80
                protocol = "tcp"
        }

	tags = {
		Name = "my-sg"
	}
}


