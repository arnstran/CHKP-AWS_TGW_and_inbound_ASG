# Check Point R80 BYOL
data "aws_ami" "chkp_ami" {
  most_recent      = true
  filter {
    name   = "name"
    values = ["Check Point CloudGuard IaaS GW BYOL R80.30-*"]
  }
  owners = ["679593333241"]
}

# Ubuntu Image
data "aws_ami" "ubuntu_ami_16_04" {
  most_recent      = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
  owners = ["099720109477"] # Canonical
}

# New keypair
resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name2}"
  public_key = "${file(var.public_key_path)}"
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "ext-lb" {
  name        = "terraform_example_lb"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.inbound_vpc.id}"

  # Open access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8088
    to_port     = 8088
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# The external LB
resource "aws_lb" "sgw" {
  name = "terraform-external-alb"
  internal           = false
  load_balancer_type = "application"
  subnets         = ["${aws_subnet.inbound_external_subnet.*.id}"]
  security_groups = ["${aws_security_group.ext-lb.id}"]
}

resource "aws_lb_target_group" "sgw8090" {
  name     = "terraform-external-tg8090"
  port     = 8090
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.inbound_vpc.id}"
}

resource "aws_lb_listener" "sgw80" {
  load_balancer_arn = "${aws_lb.sgw.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.sgw8090.arn}"
  }
}

 resource "aws_lb_target_group" "sgw8091" {
  name     = "terraform-external-tg8091"
  port     = 8091
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.inbound_vpc.id}"
}

resource "aws_lb_listener" "sgw8080" {
  load_balancer_arn = "${aws_lb.sgw.arn}"
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.sgw8091.arn}"
  }
}

resource "aws_lb_target_group" "sgw8092" {
  name     = "terraform-external-tg8092"
  port     = 8092
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.inbound_vpc.id}"
}

resource "aws_lb_listener" "sgw8088" {
  load_balancer_arn = "${aws_lb.sgw.arn}"
  port              = "8088"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.sgw8092.arn}"
  }
}

# The internal LB
resource "aws_lb" "web" {
  name = "terraform-internal-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets         = ["${aws_subnet.inbound_internal_subnet.*.id}"]
  tags {
    x-chkp-tags = "management=${var.management_server_name}:template=${var.template_name}"
  }            
}

resource "aws_lb_target_group" "web80" {
  name     = "terraform-internal-tg80"
  port     = 80
  protocol = "TCP"
  vpc_id   = "${aws_vpc.inbound_vpc.id}"
}

resource "aws_lb_listener" "web8090" {
  load_balancer_arn = "${aws_lb.web.arn}"
  port              = "8090"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.web80.arn}"
  }
}

resource "aws_lb_target_group" "web3000" {
  name     = "terraform-internal-tg3000"
  port     = 3000
  protocol = "TCP"
  vpc_id   = "${aws_vpc.inbound_vpc.id}"
}

resource "aws_lb_listener" "web8091" {
  load_balancer_arn = "${aws_lb.web.arn}"
  port              = "8091"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.web3000.arn}"
  }
}

# The internal web LB
resource "aws_lb" "web-private" {
  name = "terraform-internal-nlb2"
  internal           = true
  load_balancer_type = "network"
  subnets         = ["${aws_subnet.private_internal_subnet.*.id}"]
  tags {
    x-chkp-tags = "management=${var.management_server_name}:template=${var.template_name}"
  }            
}

resource "aws_lb_target_group" "int80" {
  name     = "terraform-internal-int80"
  port     = 80
  protocol = "TCP"
  vpc_id   = "${aws_vpc.private_vpc.id}"
}

resource "aws_lb_target_group_attachment" "int80" {
  target_group_arn = "${aws_lb_target_group.int80.arn}"
  target_id        = "${aws_instance.private_instance.id}"
  port             = 80
}

resource "aws_lb_listener" "web8092" {
  load_balancer_arn = "${aws_lb.web-private.arn}"
  port              = "8092"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.int80.arn}"
  }
}

# CHKP Inbound ASG
resource "aws_launch_configuration" "sgw_conf" {
  name          = "sgw_config"
  image_id      = "${data.aws_ami.chkp_ami.id}"
  instance_type = "${var.cg_size}" 
  key_name      = "${aws_key_pair.auth.id}"
  security_groups = ["${aws_security_group.inbound_security_group.id}"]
#  user_data     = "${var.my_user_data}"
  associate_public_ip_address = true
  user_data     = <<-EOF
                #!/bin/bash
                clish -c 'set user admin shell /bin/bash' -s
                blink_config -s 'gateway_cluster_member=false&ftw_sic_key=${var.sic_key}&upload_info=true&download_info=true&admin_hash="${var.password_hash}"'
                addr="$(ip addr show dev eth0 | awk "/inet/{print \$2; exit}" | cut -d / -f 1)"
                dynamic_objects -n LocalGateway -r "$addr" "$addr" -a
                EOF

}

resource "aws_autoscaling_group" "sgw_asg" {
  name = "cg-layer-autoscale"
  launch_configuration = "${aws_launch_configuration.sgw_conf.id}"
  max_size = 4
  min_size = 2
  target_group_arns = ["${aws_lb_target_group.sgw8090.arn}","${aws_lb_target_group.sgw8091.arn}","${aws_lb_target_group.sgw8092.arn}"]
  vpc_zone_identifier = ["${aws_subnet.inbound_external_subnet.*.id}"]

  tag {
      key = "Name"
      value = "CHKP-AutoScale"
      propagate_at_launch = true
  }
  tag {
      key = "x-chkp-tags"
      value = "management=${var.management_server_name}:template=${var.template_name}"
      propagate_at_launch = true
  }


}

# Web server ASG
resource "aws_launch_configuration" "web_conf" {
  name          = "web_config"
  image_id      = "${data.aws_ami.ubuntu_ami_16_04.id}"
  instance_type = "${var.ws_size}"
  key_name      = "${aws_key_pair.auth.id}"
  security_groups = ["${aws_security_group.inbound_security_group.id}"]
  user_data     = "${var.ubuntu_user_data}"
  associate_public_ip_address = true
}

resource "aws_autoscaling_group" "web_asg" {
  name = "web-layer-autoscale"
  launch_configuration = "${aws_launch_configuration.web_conf.id}"
  max_size = 4
  min_size = 2
  health_check_grace_period = 5
  target_group_arns = ["${aws_lb_target_group.web80.arn}","${aws_lb_target_group.web3000.arn}"]
  vpc_zone_identifier = ["${aws_subnet.inbound_internal_subnet.*.id}"]
  tag {
      key = "Name"
      value = "web-AutoScale"
      propagate_at_launch = true
  }
  tag {
      key = "data-profile"
      value = "PCI"
      propagate_at_launch = true
  }
}

output "ext_lb_dns" {
  value = "${aws_lb.sgw.dns_name}"
}

//data "aws_route53_zone" "selected" {
//  name         = "domain.com."
//}

//resource "aws_route53_record" "iac-demo" {
//  zone_id = "${data.aws_route53_zone.selected.zone_id}"
//  name    = "${var.externaldnshost}.${var.r53zone}"
//  type    = "A"
//  alias {
//    name                   = "${aws_elb.sgw.dns_name}"
//    zone_id                = "${aws_elb.sgw.zone_id}"
//    evaluate_target_health = true
//  }
//}