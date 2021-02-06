# Controller
aws_account_name = "cloudN-demo" # Name used to onboard AWS account in the Aviatrix controller
aws_profile      = # AWS profile configured in aws-cli

# Test instances in the spoke VPCs (non iperf)
# if create_key = true, set both below to false, run terraform apply
# change to true and run terraform apply again
# otherwise AWS provider will crash due to a bug
create_private_ec2 = true
create_public_ec2  = true

# Direct connect
create_VIF       = false             # set to false if you want to create infrastructure before DX has been set up
connection_id    = ""                # Check "Direct Connect -> connections"
aws_vlan         = ""                # Check "Direct Connect -> connections" 
vif_name         = "cloudN-demo-10Gbps"
amazon_address   = "10.255.255.2/30" # DON'T change, preconfigured on the cloudN side
amazon_side_asn  = 64512             # DON'T change, preconfigured on the cloudN side
customer_address = "10.255.255.1/30" # DON'T change, preconfigured on the cloudN side
bgp_asn          = 65000             # DON'T change, preconfigured on the cloudN side
jumbo_frames     = false             # Currently jumbo frames are disabled on cloudN and transit gateways

# Transit
aws_region_1        = "us-west-1"
aws_transit_name_1  = "Transit-west-1"
aws_transit_cidr_1  = "10.100.0.0/22"
aws_transit_gw_size = "c5n.4xlarge" # bump to c5n.4xlarge for performance tests
aws_spoke_gw_size   = "c5n.2xlarge" # bump to c5n.2xlarge for performance tests

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

# iperf servers - configured to run iperf at boot on port 8000
aws_iperf_instance_type   = "c5n.2xlarge" # c5n.large can handle max ~ 6Gbps at 1370 MTU, c5n.2xlarge maxes around 11 Gbps within VPC
aws_iperf_instance_number = 1             # No of instances per AZ

