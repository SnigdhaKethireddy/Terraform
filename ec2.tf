provider "aws" {
  region  = "us-east-1"
}

resource "vpc" "my_vpc" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = vpc.my_vpc.id

#   tags = {
#     Name = "main"
#   }
}

resource "aws_route_table" "route" {
  vpc_id = vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

}

resource "aws_subnet" "my_subnet" {
  vpc_id            = vpc.my_vpc.id
  cidr_block        = "10.1.10.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_route_table_association" "rt" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.route.id
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  vpc_id      = vpc.my_vpc.id

  ingress {
    description      = "http protocols"
    from_port        = 80
    to_port          = 80
    protocol         = "http"
    cidr_blocks      = ["0.0.0.0./0"] 
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
  

resource "aws_network_interface" "ni" {
  subnet_id       = aws_subnet.my_subnet.id
  private_ips     = ["10.0.0.50"]
  security_groups = [aws_security_group.allow_tls.id]
}

resource "aws_eip" "eip" {
#   instance = aws_instance.web.id
  vpc      = true
  network_interface = aws_network_interface.ni.id
  associate_with_private_ip = "10.0.0.1"
  depends = [aws_internet_gateway.gw.id]
}

resource "instance" "size" {
  description = "enter the size of the instace"  
}

resource "aws_instance" "ec2" {
  ami           = "" 
  instance_type = var.instance
  availability_zone = "us-east-1a"
  key =""

  network_interface {
    device_index = 0 //first nwi specified with this 
    network_interface_id = aws_network_interface.ni.id

  }
  user_data = <<-EOF
               #! /bin/bash
                sudo apt-get update
                sudo apt-get install -y apache2
                sudo systemctl start apache2
                echo " web server" /var/www/html/index.html
               EOF
}


