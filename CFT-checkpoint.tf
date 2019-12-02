##########################################
########### Outbound VPC  ################
##########################################

# Deploy CP TGW cloudformation template
resource "aws_cloudformation_stack" "checkpoint_tgw_cloudformation_stack" {
  name = "${var.project_name}-Gateway-TGW"

  parameters {
    VPC                                         = "${aws_vpc.outbound_vpc.id}"
    Subnets                                     = "${join(",",aws_subnet.outbound_external_subnet.*.id)}"
    KeyPairName                                 = "${var.key_name}"
    AllowUploadDownload                         ="Yes"
    Shell                                       = "/bin/bash"
    Name                                        = "${var.project_name}-CheckPoint-TGW"
    GatewaysInstanceType                        = "c5.large"
    GatewaysMinSize                             = "2"
    GatewaysMaxSize                             = "5"
    GatewaysLicense                             = "R80.30-BYOL"
    GatewaysPasswordHash                        = "${var.password_hash}"
    GatewaysSIC                                 = "${var.sic_key}"
    AdminEmail                                  = "${var.admin_email}"
    ManagementDeploy                            = "No"
    ControlGatewayOverPrivateOrPublicAddress    = "public"
    ManagementServer                            = "${var.management_server_name}"
    ConfigurationTemplate                       = "${var.tgw_configuration_template_name}"
  }

  template_url        = "https://s3.amazonaws.com/CloudFormationTemplate/checkpoint-tgw-asg.yaml"
  capabilities        = ["CAPABILITY_IAM"]
  disable_rollback    = true
  timeout_in_minutes  = 50
}
