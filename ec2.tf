provider "aws" {

#   access_key="AKIAJS307JXZRDKIY5WQ"
#   secret_key="23jHGbZ+UGjyCHoPgizEVw8dPnGErKfFTGS/GgLK"
  region  = "us-east-1"
}

resource "aws_instance" "ec2" {
#   ami           = "ami-085925f297f89fce1"
  instance_type = "t2.micro"
  }