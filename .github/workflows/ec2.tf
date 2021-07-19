provider "aws" {
  access_key = ""
  secret_key= ""
  region  = "us-east-1"
}
#create a vpc
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}
#create internet gateway 
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# create custom route table

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

}

#create subnet
resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

#associate subnet with route table
resource "aws_route_table_association" "rt" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.route.id
}

#create security group allow port 80
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] 
  }
  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] 
  }
  ingress {
    description      = "https"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] 
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
  
#create network interface
resource "aws_network_interface" "ni" {
  subnet_id       = aws_subnet.my_subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_tls.id]
}

#assign eip to network interface
resource "aws_eip" "eip" {
#   instance = aws_instance.web.id
  vpc      = true
  network_interface = aws_network_interface.ni.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw]
}

#create a server install apache

resource "aws_instance" "ec2" {
  ami           = "ami-09e67e426f25ce0d7" 
  instance_type = var.size
  availability_zone = "us-east-1a"
  iam_instance_profile = aws_iam_instance_profile.test_profile.name
  key_name ="mykey"
  

  network_interface {
    device_index = 0 //first nwi specified with this 
    network_interface_id = aws_network_interface.ni.id

  }

  user_data = <<-EOF
                #!/bin/bash
                sudo su
                yum -y install http
                echo "<p> My Instance! </p>" >> /var/www/html/index.html
                sudo systemctl enable http
                sudo systemctl start http
               EOF
}


///////////////

#create s3 bucket
resource "aws_s3_bucket" "b" {
  bucket = "for-practice-aws"
  acl    = "public-read"
}

#assign iam role
resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

}
//ec2 instane profile

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.test_role.name
}

#assign policy

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.test_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

