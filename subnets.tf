##########################################
########### Inbound VPC  ##############
##########################################

# Create subnets to launch our instances into
resource "aws_subnet" "inbound_external_subnet" {
  count             = "${length(data.aws_availability_zones.azs.names)}"
  availability_zone = "${element(data.aws_availability_zones.azs.names, count.index)}"
  vpc_id            = "${aws_vpc.inbound_vpc.id}"
  cidr_block        = "${cidrsubnet(var.inbound_cidr_vpc, 8, count.index+100 )}"
  
  tags {
    Name = "${var.project_name}-Inbound-External-${count.index+1}"
  }
}

resource "aws_subnet" "inbound_internal_subnet" {
  count             = "${length(data.aws_availability_zones.azs.names)}"
  availability_zone = "${element(data.aws_availability_zones.azs.names, count.index)}"
  vpc_id            = "${aws_vpc.inbound_vpc.id}"
  cidr_block        = "${cidrsubnet(var.inbound_cidr_vpc, 8, count.index+200 )}"
  
  tags {
    Name = "${var.project_name}-Inbound-Internal-${count.index+1}"
  }
}

##########################################
########### Outbound VPC  ##############
##########################################

# Create subnets to launch our instances into
resource "aws_subnet" "outbound_external_subnet" {
  count             = "${length(data.aws_availability_zones.azs.names)}"
  availability_zone = "${element(data.aws_availability_zones.azs.names, count.index)}"
  vpc_id            = "${aws_vpc.outbound_vpc.id}"
  cidr_block        = "${cidrsubnet(var.outbound_cidr_vpc, 8, count.index+100 )}"
  
  tags {
    Name = "${var.project_name}-Outbound-External-${count.index+1}"
  }
}

#####################################
########### Private VPC  ##############
#####################################

# Create a subnet to launch our instances into
resource "aws_subnet" "private_internal_subnet" {
  count             = "${length(data.aws_availability_zones.azs.names)}"
  availability_zone = "${element(data.aws_availability_zones.azs.names, count.index)}"
  vpc_id            = "${aws_vpc.private_vpc.id}"
  cidr_block        = "${cidrsubnet(var.private_cidr_vpc, 8, count.index+100 )}"
  
  tags {
    Name = "${var.project_name}-Private-Internal-${count.index+1}"
  }
}

######################################
########### Test VPC  ################
######################################

# Create a subnet to launch our instances into
resource "aws_subnet" "test_external_subnet" {
  vpc_id     = "${aws_vpc.test_vpc.id}"
  cidr_block = "${var.test_cidr_vpc}"
  
  tags {
    Name = "${var.project_name}-Test-External"
  }
}