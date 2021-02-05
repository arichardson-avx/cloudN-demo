# Controller
controller_ip      = 
username           = "admin"
password           = 
aws_account_name   =  # Name used to onboard AWS account in the Aviatrix controller
azure_account_name = "cloudN-Azure"

# Azure - this is info you would provide when onboarding Azure in the controller, TF onboards the subscription below
azure_subscription_id = 
arm_directory_id      = 
arm_application_id    = 
arm_application_key   = 

# Cloud instances access
# Set below to false if you deployed the controller by provided TF or want to use own key
create_key    = false         # Provide existing key name below if set to false
key_name      = "cloudN-demo" # If you created a key in controller TF, the key name will be "cloudN-demo"
ssh_addresses = []             # IP addresses allowed to access cloud infrastructure, format ["x.x.x.x/yy,"z.z.z.z/qq"]

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

# Direct connect
create_VIF       = true                # set to false if you want to create infrastructure before DX has been set up
connection_id    =                     # Check "Direct Connect -> connections" 
vlan             =                     # Check "Direct Connect -> connections" 
vif_name         = "cloudN-demo-10Gbps"
amazon_address   = "10.255.255.2/30 "  # DON'T change, preconfigured on the cloudN side
amazon_side_asn  = 64512               # DON'T change, preconfigured on the cloudN side
customer_address = "10.255.255.1/30"   # DON'T change, preconfigured on the cloudN side
bgp_asn          = 65000               # DON'T change, preconfigured on the cloudN side
jumbo_frames     = false               # Currently jumbo frames are disabled on cloudN and transit gateways

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
aws_iperf_instance_type   = "c5n.2xlarge" # c5n.large can handle max ~ 6Gbps at 1370 MTU, c5n.2xlarge maxes around 11 Gbps within VPC
aws_iperf_instance_number = 1  # No of instances per AZ

# Azure
azure_region_1        = "West US"
azure_transit_name_1  = "Azure-transit-west"
azure_transit_cidr_1  = "10.110.0.0/22"
azure_transit_gw_size = "Standard_D32_v3" # bump to Standard_D32_v3 for performance tests max 16 Gbps, 48 - 24Gbps, 64 - 30Gbps
azure_spoke_gw_size   = "Standard_D32_v3" #"Standard_D3_v2" # min "Standard_D3_v2" for HPE max 3 Gbps,  Standard_D5_v2 can do 12 Gbps

# Spoke VNETs
vnet_data_region_1 = {
  vnet1 = {
    name = "Prod-Azure"
    cidr = "10.210.1.0/24"
  }
  vnet2 = {
    name = "Dev-Azure"
    cidr = "10.210.2.0/24"
  }
}

azure_iperf_instance_number  = 1
azure_iperf_instance_type    = "Standard_D16_v3" # Max 8Gbps, D32 - 16Gbps
azure_iperf_fixed_private_ip = true
azure_iperf_private_ip       = "40"       

create_private_vm = true
create_public_vm  = true
ubuntu_password   = "Aviatrix123#"

# Azure Express Route
create_peering        = false # set to false when deleting ER 
azure_peer_prefix_pri = "10.255.255.20/30" # Don't change, preconfigured on the ASR
azure_peer_prefix_sec = "10.255.255.24/30" # Don't change, preconfigured on the ASR