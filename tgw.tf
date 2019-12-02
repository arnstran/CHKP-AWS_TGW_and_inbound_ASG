#####################################
######### Transit GW  ###############
#####################################

# Create the TGW
resource "aws_ec2_transit_gateway" "transit_gateway" {
  description = "${var.project_name} Tansit GW"
  tags {
    Name        = "${var.project_name}-TransitGW"
    x-chkp-vpn  = "${var.management_server_name}/${var.tgw_community_name}"
  }
}

# Attach TGW to the Inbound VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "inbound_transit_gateway_vpc_attachment" {
  subnet_ids         = ["${aws_subnet.inbound_external_subnet.*.id}"]
  transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  vpc_id             = "${aws_vpc.inbound_vpc.id}"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags {
    Name = "${var.project_name}-Inbound-TGW-Attachment"
  }
} 

# Attach TGW to private VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "private_transit_gateway_vpc_attachment" {
  subnet_ids         = ["${aws_subnet.private_internal_subnet.*.id}"]
  transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  vpc_id             = "${aws_vpc.private_vpc.id}"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags {
    Name = "${var.project_name}-Private-TGW-Attachment"
  }
}

# Attach TGW to Test VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "test_transit_gateway_vpc_attachment" {
  subnet_ids         = ["${aws_subnet.test_external_subnet.id}"]
  transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  vpc_id             = "${aws_vpc.test_vpc.id}"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags {
    Name = "${var.project_name}-Test-TGW-Attachment"
  }
}
