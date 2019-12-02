data "aws_ami" "ubuntu_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

#############################################
########### Private Web Server  ##############
#############################################

locals {
  website = <<WEBSITE
sudo echo "" > index.html
sudo echo "Greetings!" >> index.html
sudo echo "----------" >> index.html
sudo echo "" >> index.html
sudo echo "This is a private web server!" >> index.html
sudo echo "" >> index.html
sudo nohup busybox httpd -f -p 80 &
sudo sleep 5
WEBSITE
}

resource "aws_instance" "private_instance" {
  ami                         = "${data.aws_ami.ubuntu_ami.id}"
  instance_type               = "t2.nano"
  #count                       = "${length(data.aws_availability_zones.azs.names)}"
  count = 1
  availability_zone           = "${element(data.aws_availability_zones.azs.names, count.index)}"
  subnet_id                   = "${element(aws_subnet.private_internal_subnet.*.id,count.index)}"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = "false"
  vpc_security_group_ids      = ["${aws_security_group.private_security_group.id}"]

    user_data = <<-EOF
              #!/bin/bash
              echo "${local.website}" >> website.sh
              chmod +x website.sh
              mv ./website.sh /home/ubuntu/
              sudo echo "" > index.html
              sudo echo "Greetings!" >> index.html
              sudo echo "----------" >> index.html
              sudo echo "" >> index.html
              sudo echo "This is a private web server!" >> index.html
              sudo echo "" >> index.html
              sudo nohup busybox httpd -f -p 80 &
              sudo sleep 5
              EOF

  tags {
    Name        = "${var.project_name}-Private Web Server"
    Server      = "${var.project_name}-Website"
    Environment = "Dev"
  }
}

output "Private-Web_IP" {
  value = "${aws_instance.private_instance.private_ip}"
	description = "The Private IP of the Private Web server"
}

######################################
########### Test client ##############
######################################

resource "aws_instance" "test_instance" {
  ami                         = "${data.aws_ami.ubuntu_ami.id}"
  instance_type               = "t2.nano"
  subnet_id                   = "${aws_subnet.test_external_subnet.id}"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = "true"
  vpc_security_group_ids      = ["${aws_security_group.test_security_group.id}"]
			  
  tags {
    Name    = "${var.project_name}-Test"
    Dev-Test    = "false"
    Prod-Test   = "true"
  }
}
output "test-Ubuntu_IP" {
  value = "${aws_instance.test_instance.public_ip}"
	description = "The Public IP of the Jumphost"
}