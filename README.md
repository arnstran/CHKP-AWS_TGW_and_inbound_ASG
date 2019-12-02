# CHKP-AWS_TGW_and_inbound_ASG
Deploys Check Point ASG solutions in AWS using Terraform. Outbound ASG/VPC with Transit Gateway and inbound ASG/VPC.
Also deloys VPC's with jumphost and web servers for a complete environment.

Requirements:
- Terraform installed on a machine (Terraform version 0.11.15 tested. 0.12 needs 'terraform 0.12upgrade' after the 'terraform init')
- An existing R80.30 Check Point Management installed.
- The management must be prepared with autoprovision and policy for the TGW
    - https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_AWS_Transit_Gateway/html_frameset.htm
- And the management must be prepared with autoprovision and policy for the Inbound ASG
    - https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk112575
- AWS credentials in variable file or better as Environment Variables on the host:

Example added to the end of .bashrc on your host:

export AWS_ACCESS_KEY_ID='XXXXXXXXXXXXXXXXX'

export AWS_SECRET_ACCESS_KEY='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

export AWS_REGION=eu-central-1


Notes:
- Management server communicate with gateways over public IPs
- R80.30 gateways will be deployed


Run:
Before you run the templates, variables.tf needs to be updated. At least key_name, password_hash, sic_key, admin_email and public_key_path. 
And make sure relevant variables (management_server_name, template_name, tgw_configuration_template_name and tgw_community_name) matches your Management server autoprovision configuration that you did above.

Put the files in a directory (download or git clone) on your host (the host where terraform is installed), and from that directory run:
- 'terraform init'
- 'terraform 0.12upgrade' (only if terraform version 0.12 is used)
- 'terraform plan' (optional)
- 'terraform apply'


Testing: When the deployment finishes, it prints the IP of the Jumphost, web app DNS name and private IP of a internal web server.

- When the deployment finished it still takes 10-15 minutes for all the Check Point autoprovison to finish.
- Test published web apps by browsing to web app DNS name. There are different web applications on port 80, 8080 and 8088.
- Test between spokes (E/W) by SSH'ing to the Jumphost (user: 'ubuntu' and need to use AWS key for authentication) and pinging the private web server in the other spoke (10.210.100.x).
- Test outbound by pinging 8.8.8.8
- Verify logs in SmartConsole


Stop/destroy: When finished, stop instances or run 'terraform destroy' to remove the deployment


Known issues:
- Sometimes 'terraform destroy' fails. A rerun or two fixes it.
