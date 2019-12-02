data "aws_availability_zones" "azs" {}

# Inbound VPC
variable "inbound_cidr_vpc" {
  description = "Inbound VPC"
  default     = "10.110.0.0/16"
}

# Outbound VPC
variable "outbound_cidr_vpc" {
  description = "Outbound VPC"
  default     = "10.120.0.0/16"
}

# VPC hosting out private facing website
variable "private_cidr_vpc" {
  description = "VPC hosting a private facing website"
  default     = "10.210.0.0/16"
}

# VPC hosting a test endpoint
variable "test_cidr_vpc" {
  default = "10.230.0.0/16"
}

# Private key
variable "key_name" {
  default = ""
}

# SIC key
variable "sic_key" {
  default = ""
}
# Admin Email key
variable "admin_email" {
  default = ""
}
variable "password_hash" {
  description = "Password for the Check Point servers"
  default     = ""
}

variable "management_server_name" {
  description = "The name of the management server in the cloudformation template"
  default     = "mgmt"
}

variable "template_name" {
  description = "The template used in CME (autoprov_cfg)"
  default     = "Inbound-ASG-configuration"
}

variable "tgw_configuration_template_name" {
  description = "The name of the tgw template name in the cloudformation template"
  default     = "TGW-ASG-configuration"
}

variable "tgw_community_name" {
  description = "The name of the tgw community in Smartconsole"
  default     = "tgw-community"
}

variable "project_name" {
  default = "TF-TGW"
}

variable "cg_size" {
  default = "c5.large"
}

variable "ws_size" {
  default = "t2.micro"
}

variable "externaldnshost" {
  default = "cg-demo"
}

variable "r53zone" {
  default = "domain.com."
}

variable "key_name2" {
  default = "AWS_pub_key"
}

variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

//variable "my_user_data" {
//}

variable "ubuntu_user_data" {
  default = <<-EOF
                    #!/bin/bash
                    until sudo apt-get update && sudo apt-get -y install apache2;do
                      sleep 1
                    done
                    until curl \
                      --output /var/www/html/CloudGuard.png \
                      --url https://www.checkpoint.com/wp-content/uploads/cloudguard-hero-image.png ; do
                       sleep 1
                    done
                    sudo chmod a+w /var/www/html/index.html 
                    echo "<html><head><meta http-equiv=refresh content="5" /> </head><body><center><H1>" > /var/www/html/index.html
                    echo $HOSTNAME >> /var/www/html/index.html
                    echo "<BR><BR>Check Point CloudGuard ASG Demo <BR><BR>Any Cloud, Any App, Unmatched Security<BR><BR>" >> /var/www/html/index.html
                    echo "<img src=\"/CloudGuard.png\" height=\"25%\">" >> /var/www/html/index.html
                    until curl -fsSL https://get.docker.com -o get-docker.sh;do
                      sleep 1
                    done
                    until sh get-docker.sh;do
                      sleep 1
                    done
                    until sudo docker pull bkimminich/juice-shop:v7.5.1;do
                      sleep 1
                    done
                    until sudo docker run -d -p 3000:3000 bkimminich/juice-shop:v7.5.1;do
                      sleep 1
                    done
                    EOF
}

//variable "Current_Public_IP" {
//  description = "Your current public_IP to access to VM"
//  default     = "1.2.3.4/32"
//}
