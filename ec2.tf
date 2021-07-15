provider "aws" {
  region  = "us-east-1"
}

resource "aws_instance" "ec2" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"
}