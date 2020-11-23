# Controller
controller_ip    = 
username         = "admin"
password         = 
aws_account_name =  # Name used to onboard AWS account in the Aviatrix controller

# Cloud Access
# Set below to false if you deployed the controller by provided TF or want to use own key
create_key    = false         # Provide existing key name below if set to false
key_name      = "cloudN-demo" # If you created a key in controller TF, the key name will be "cloudN-demo"
ssh_addresses =               # IP addresses allowed to access cloud infrastructure, format ["x.x.x.x/yy,"z.z.z.z/qq"]

# Test instances in the spoke VPCs (non iperf)
# if create_key = true, set both below to false, run terraform apply, change to true and run terraform apply again
# AWS provider will crash due to a bug if terraform apply run with instances set to true
create_private_ec2 = true 
create_public_ec2  = true


# AWS
aws_profile         =  # AWS profile configured in aws-cli
aws_region_1        = "us-west-1"
aws_transit_name_1  = "Transit-west-1"
aws_transit_cidr_1  = "10.100.0.0/22"
aws_transit_gw_size = "c5n.4xlarge"
aws_spoke_gw_size   = "c5n.2xlarge" 

# Spoke VPCs
vpc_data_region_1 = {
  vpc1 = {
    name = "Prod"
    cidr = "10.200.1.0/24"
  }
  vpc2 = {
    name = "Dev"
    cidr = "10.200.2.0/24"
  }
}

# iperf servers - configured to run iperf at boot, port 8000
aws_iperf_instance_type   = "c5n.large"
aws_iperf_instance_number = 1  # No of instances per AZ


# Direct connect
create_10G_VIF   = true                # set to false if you want to create infrastructure before DX has been set up
connection_id    =                     # Check "Direct Connect -> connections" 
vlan             =                     # Check "Direct Connect -> connections" 
vif_name         = "cloudN-demo-10Gbps"
amazon_address   = "10.255.255.2/30 "  # DON'T change, preconfigured on the cloudN side
amazon_side_asn  = 64512               # DON'T change, preconfigured on the cloudN side
customer_address = "10.255.255.1/30"   # DON'T change, preconfigured on the cloudN side
bgp_asn          = 65000               # DON'T change, preconfigured on the cloudN side
jumbo_frames     = false               # Currently jumbo frames are disabled on cloudN and transit gateways


