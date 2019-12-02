provider "aws" {
        version = "~> 2.33.0"
}

# currently used in conjuction with using
# icanhazip.com to determine local workstation external IP
# to open EC2 Security Group access to the Jumphost.
# See workstation-external-ip.tf for additional information.
provider "http" {}

##########################################
########### Inbound VPC  ##############
##########################################

# Create a VPC for the Inbound ASG
resource "aws_vpc" "inbound_vpc" {
  cidr_block            = "${var.inbound_cidr_vpc}"
  enable_dns_hostnames  = "true"
  
  tags {
    Name = "${var.project_name}-Inbound-VPC"
  }
}

# Create an internet gateway to give internet access
resource "aws_internet_gateway" "inbound_internet_gateway" {
  vpc_id = "${aws_vpc.inbound_vpc.id}"
  
  tags {
    Name   = "${var.project_name}-Inbound-IGW"
  }
}

# A permissive security group
resource "aws_security_group" "inbound_security_group" {
  vpc_id     = "${aws_vpc.inbound_vpc.id}"
  
  # Full inbound access
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }    
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }     
  
  tags {
    Name   = "${var.project_name}-Inbound-SG"
  }
}


##########################################
########### Outbound VPC  ##############
##########################################

# Create a VPC for the Outbound ASG
resource "aws_vpc" "outbound_vpc" {
  cidr_block            = "${var.outbound_cidr_vpc}"
  enable_dns_hostnames  = "true"
  
  tags {
    Name = "${var.project_name}-Outbound-VPC"
  }
}

# Create an internet gateway to give internet access
resource "aws_internet_gateway" "outbound_internet_gateway" {
  vpc_id = "${aws_vpc.outbound_vpc.id}"
  
  tags {
    Name   = "${var.project_name}-outbound-IGW"
  }
}

# A permissive security group
resource "aws_security_group" "outbound_security_group" {
  vpc_id     = "${aws_vpc.outbound_vpc.id}"
  
  # Full inbound access
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }    
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }     
  
  tags {
    Name   = "${var.project_name}-Outbound-SG"
  }
}

######################################
########### Private VPC  ##############
######################################

# Create a VPC to launch the private facing web server into
resource "aws_vpc" "private_vpc" {
  cidr_block            = "${var.private_cidr_vpc}"
  enable_dns_hostnames  = "true"
  
  tags {
    Name = "${var.project_name}-Private-VPC"
  }
}

# A security group to give access via the web
resource "aws_security_group" "private_security_group" {
  vpc_id     = "${aws_vpc.private_vpc.id}"
  
  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  
  # ICMP from anywhere
  ingress {
    from_port   = "-1"
    to_port     = "-1"
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }   
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }    

  tags {
    Name   = "${var.project_name}-Private-SG"
  }  
}

######################################
########### Test VPC  ################
######################################

# Create a VPC to launch the web server into
resource "aws_vpc" "test_vpc" {
  cidr_block            = "${var.test_cidr_vpc}"
  enable_dns_hostnames  = "true"
  
  tags {
    Name = "${var.project_name}-Test-VPC"
  }
}
# Create an internet gateway to give internet access
resource "aws_internet_gateway" "testvpc_internet_gateway" {
  vpc_id = "${aws_vpc.test_vpc.id}"
  
  tags {
    Name   = "${var.project_name}-test-vpc-IGW"
  }
}
# A security group to give access via the web
resource "aws_security_group" "test_security_group" {
  vpc_id     = "${aws_vpc.test_vpc.id}"
  
  # Full tester inbound access
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }    
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }     
  
  tags {
    Name   = "${var.project_name}-Test-SG"
  }
}
