# Terraform


Resources used- https://registry.terraform.io/providers/hashicorp/aws/latest/docs


Steps to spin an  EC2 instance with given conditions

Created 3 files,
ec2.tf-spinning up ec2 instances
autoscale.tf-to autoscale instances
elb.tf-load balancer


#create a vpc
#create internet gateway 
#create custom route table
#create subnet
#associate subnet with route table
#create security group allow port 80
#create network interface
#assign eip to network interface
#create a server install apache
#run userdata script
#create s3 bucket
#assign iam role
#ec2 instane profile
#assign policy
