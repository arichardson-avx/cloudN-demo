# Controller
azure_account_name = "cloudN-Azure"

# Azure access - this is info you would provide when onboarding Azure in the controller, TF onboards the subscription below
azure_subscription_id = 
arm_directory_id      = 
arm_application_id    = 
arm_application_key   = 

# Express route
create_peering        = false # set to false before receiving confirmation on L2 circuit 
azure_peer_prefix_pri = "10.255.255.20/30" # Don't change, preconfigured on the ASR
azure_peer_prefix_sec = "10.255.255.24/30" # Don't change, preconfigured on the ASR
azure_vlan            = 801                # Don't change


# Transit
azure_region_1        = "West US"
azure_transit_name_1  = "Azure-transit-west"
azure_transit_cidr_1  = "10.110.0.0/22"
azure_transit_gw_size = "Standard_D32_v3" #"Standard_D8_v3" # bump to Standard_D32_v3 for performance tests max 16 Gbps, 48 - 24Gbps, 64 - 30Gbps
azure_spoke_gw_size   = "Standard_D16_v3" #"Standard_D8_v3" #"Standard_D3_v2" # min "Standard_D3_v2" for HPE max 3 Gbps,  Standard_D5_v2 can do 12 Gbps

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

# Test instances in the spoke VPCs (non iperf)
create_private_vm = true
create_public_vm  = true
ubuntu_password   = "Aviatrix123#"

# iperf servers - configured to run iperf at boot on port 8000
azure_iperf_instance_number  = 1
azure_iperf_instance_type    = "Standard_D16_v3" # Max 8Gbps, D32 - 16Gbps
azure_iperf_fixed_private_ip = true
azure_iperf_private_ip       = "30" 



