provider "aws" {
  region  = var.aws_region_1
  profile = var.aws_profile
  alias   = "region_1"
}


module "aviatrix-create-transit-net-area-1" {
  source = "./aws_transit"

  region           = var.aws_region_1
  account_name     = var.aws_account_name
  aws_transit_name = var.aws_transit_name_1
  avtx_gw_size     = var.aws_transit_gw_size
  cidr             = var.aws_transit_cidr_1
  hpe              = true
  firenet          = false

  providers = {
    aws = aws.region_1
  }
}

module "aviatrix-create-avtx-vpcs-area-1" {
  source = "./aws_vpcs"

  region             = var.aws_region_1
  account_name       = var.aws_account_name
  vpc_data           = var.vpc_data_region_1 # Determines number of VPCs created
  hpe                = true
  avtx_gw_size       = var.aws_spoke_gw_size
  avx_transit_gw     = module.aviatrix-create-transit-net-area-1.avtx_gw_name
  create_private_ec2 = var.create_private_ec2
  create_public_ec2  = var.create_public_ec2
  key_name           = var.key_name
  user_data          = data.template_file.ubuntu_server.template
  fixed_private_ip   = true
  private_ip         = "10" # the last octet, module replaces xxx/xx in each subnet with this number
  ssh_addresses      = var.ssh_addresses

  providers = {
    aws = aws.region_1
  }
}

# iperf servers

module "aviatrix-create-iperf-servers-vpc-1" {
  source = "./iperf"

  instance_number       = var.aws_iperf_instance_number
  create_clients        = false
  servers_vpc           = module.aviatrix-create-avtx-vpcs-area-1.vpc_ids[0]
  servers_sg_id         = module.aviatrix-create-avtx-vpcs-area-1.public_sg_ids[0]
  servers_subnet_id_1   = module.aviatrix-create-avtx-vpcs-area-1.public_subnet_ids[0][0]
  servers_subnet_cidr_1 = module.aviatrix-create-avtx-vpcs-area-1.public_subnet_cidrs[0][0]
  servers_subnet_id_2   = module.aviatrix-create-avtx-vpcs-area-1.public_subnet_ids[0][1]
  servers_subnet_cidr_2 = module.aviatrix-create-avtx-vpcs-area-1.public_subnet_cidrs[0][1]
  key_name              = var.key_name
  instance_type         = var.aws_iperf_instance_type
  fixed_private_ip      = true
  private_ip_az_1       = "40"
  private_ip_az_2       = "60"
  ssh_addresses         = var.ssh_addresses

  providers = {
    aws = aws.region_1
  }
}

module "aviatrix-create-iperf-servers-vpc-2" {
  source = "./iperf"

  instance_number       = var.aws_iperf_instance_number
  create_clients        = false
  servers_vpc           = module.aviatrix-create-avtx-vpcs-area-1.vpc_ids[1]
  servers_sg_id         = module.aviatrix-create-avtx-vpcs-area-1.public_sg_ids[1]
  servers_subnet_id_1   = module.aviatrix-create-avtx-vpcs-area-1.public_subnet_ids[1][0]
  servers_subnet_cidr_1 = module.aviatrix-create-avtx-vpcs-area-1.public_subnet_cidrs[1][0]
  servers_subnet_id_2   = module.aviatrix-create-avtx-vpcs-area-1.public_subnet_ids[1][1]
  servers_subnet_cidr_2 = module.aviatrix-create-avtx-vpcs-area-1.public_subnet_cidrs[1][1]
  key_name              = var.key_name
  instance_type         = var.aws_iperf_instance_type
  fixed_private_ip      = true
  private_ip_az_1       = "40"
  private_ip_az_2       = "60"
  ssh_addresses         = var.ssh_addresses

  providers = {
    aws = aws.region_1
  }
}

# Direct connect
resource "aws_vpn_gateway" "vgw" {
  provider = aws.region_1

  amazon_side_asn = var.amazon_side_asn
  tags = {
    Name = "CloudN demo DX"
  }
}

resource "aws_vpn_gateway_attachment" "vgw_attachment" {
  provider = aws.region_1

  vpc_id         = module.aviatrix-create-transit-net-area-1.tvpc_id
  vpn_gateway_id = aws_vpn_gateway.vgw.id
}

resource "aws_dx_private_virtual_interface" "aws_vif" {
  count    = var.create_VIF ? 1 : 0
  provider = aws.region_1

  connection_id    = var.connection_id
  name             = var.vif_name
  vlan             = var.aws_vlan
  address_family   = "ipv4"
  amazon_address   = var.amazon_address
  customer_address = var.customer_address
  bgp_asn          = var.bgp_asn
  mtu              = var.jumbo_frames ? 9001 : 1500
  bgp_auth_key     = "Aviatrix123#" # Don't change, preconfigured on the ASR
  vpn_gateway_id   = aws_vpn_gateway.vgw.id
}
