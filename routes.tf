##########################################
########### Inbound VPC  #################
##########################################

# Create Inbound route tables
resource "aws_route_table" "inbound_route_table" {
  vpc_id     = "${aws_vpc.inbound_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.inbound_internet_gateway.id}"
  }

  # Route for Private VPC
  route {
    cidr_block          = "${var.private_cidr_vpc}"
    transit_gateway_id  = "${aws_ec2_transit_gateway.transit_gateway.id}"
  }

  # Route for Test VPC
  route {
    cidr_block          = "${var.test_cidr_vpc}"
    transit_gateway_id  = "${aws_ec2_transit_gateway.transit_gateway.id}"
  }

  # Route for linknets
  route {
    cidr_block          = "169.254.0.0/16"
    transit_gateway_id  = "${aws_ec2_transit_gateway.transit_gateway.id}"
  }

  tags {
    Name = "${var.project_name}-Inbound-Route-Table"
  }
}

resource "aws_route_table_association" "inbound_external_table_association" {
  count          = "${length(data.aws_availability_zones.azs.names)}"
  subnet_id      = "${element(aws_subnet.inbound_external_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.inbound_route_table.id}"
}

resource "aws_route_table_association" "inbound_internal_table_association" {
  count          = "${length(data.aws_availability_zones.azs.names)}"
  subnet_id      = "${element(aws_subnet.inbound_internal_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.inbound_route_table.id}"
}

##########################################
########### Outbound VPC  ################
##########################################

# Create Outbound route tables
resource "aws_route_table" "outbound_external_route_table" {
  vpc_id     = "${aws_vpc.outbound_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.outbound_internet_gateway.id}"
  }

  tags {
    Name = "${var.project_name}-Outbound-External-Route"
  }
}


resource "aws_route_table_association" "outbound_external_table_association" {
  count          = "${length(data.aws_availability_zones.azs.names)}"
  subnet_id      = "${element(aws_subnet.outbound_external_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.outbound_external_route_table.id}"
}

######################################
########### Private VPC  ##############
######################################

# Create a route table
resource "aws_route_table" "private_route_table" {
  vpc_id     = "${aws_vpc.private_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  }

  tags {
    Name = "${var.project_name}-Private-Route"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  count          = "${length(data.aws_availability_zones.azs.names)}"
  subnet_id      = "${element(aws_subnet.private_internal_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

######################################
########### Test VPC  ################
######################################

# Create/Update routes
resource "aws_route_table" "test_route_table" {
  vpc_id     = "${aws_vpc.test_vpc.id}"

  route {
    cidr_block          = "0.0.0.0/0"
	  transit_gateway_id  = "${aws_ec2_transit_gateway.transit_gateway.id}"
  }
  route {
    cidr_block          = "${local.workstation-external-cidr}"
	  gateway_id = "${aws_internet_gateway.testvpc_internet_gateway.id}"
  }
  tags {
    Name = "${var.project_name}-Test-Route"
  }
}

resource "aws_route_table_association" "test_route_table_association" {
  count          = "${length(data.aws_availability_zones.azs.names)}"
  subnet_id      = "${aws_subnet.test_external_subnet.id}"
  route_table_id = "${aws_route_table.test_route_table.id}"
}


#####################################
######### Transit GW  ###############
#####################################

#########################
######## Spokes #########
#########################
# Create a route table for the spokes VPCs
resource "aws_ec2_transit_gateway_route_table" "spoke_transit_gateway_route_table" {
  transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  tags {
    Name        = "${var.project_name}-TransitGW-Spoke-Route-Table"
    x-chkp-vpn  = "${var.management_server_name}/${var.tgw_community_name}/propagate"
  }
}

/* # Create an outbound route from the private VPC
resource "aws_ec2_transit_gateway_route" "from_private_to_outbound_transit_gateway_route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.outbound_transit_gateway_vpc_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.spoke_transit_gateway_route_table.id}"
} */

#########################
##### Check Point #######
#########################
# Create a route table for the Check Point VPC
resource "aws_ec2_transit_gateway_route_table" "checkpoint_transit_gateway_route_table" {
  transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  tags {
    Name        = "${var.project_name}-TransitGW-CheckPoint-Route-Table"
    x-chkp-vpn  = "${var.management_server_name}/${var.tgw_community_name}/associate"
  }
}

# Create route association
resource "aws_ec2_transit_gateway_route_table_association" "test_transit_gateway_route_table_association" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.test_transit_gateway_vpc_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.spoke_transit_gateway_route_table.id}"
} 

resource "aws_ec2_transit_gateway_route_table_association" "private_transit_gateway_route_table_association" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.private_transit_gateway_vpc_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.spoke_transit_gateway_route_table.id}"
} 

resource "aws_ec2_transit_gateway_route_table_association" "inbound_transit_gateway_route_table_association" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.inbound_transit_gateway_vpc_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.spoke_transit_gateway_route_table.id}"
} 

resource "aws_ec2_transit_gateway_route_table_propagation" "test_transit_gateway_route_table_propagation" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.test_transit_gateway_vpc_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.checkpoint_transit_gateway_route_table.id}"
}


resource "aws_ec2_transit_gateway_route_table_propagation" "private_transit_gateway_route_table_propagation" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.private_transit_gateway_vpc_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.checkpoint_transit_gateway_route_table.id}"
}

resource "aws_ec2_transit_gateway_route_table_propagation" "inbound_transit_gateway_route_table_propagation" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.inbound_transit_gateway_vpc_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.checkpoint_transit_gateway_route_table.id}"
}
