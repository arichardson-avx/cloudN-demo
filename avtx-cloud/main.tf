provider "aviatrix" {
  username      = var.username
  password      = var.password
  controller_ip = var.controller_ip
}

provider "aws" {
  region  = var.aws_region_1
  profile = var.aws_profile
  alias   = "region_1"
}

provider "azurerm" {
  subscription_id = var.azure_subscription_id
  client_id       = var.arm_application_id
  client_secret   = var.arm_application_key
  tenant_id       = var.arm_directory_id
  features {}
}

resource "aviatrix_account" "azure_account" {
  account_name        = var.azure_account_name
  cloud_type          = 8
  arm_subscription_id = var.azure_subscription_id
  arm_directory_id    = var.arm_directory_id
  arm_application_id  = var.arm_application_id
  arm_application_key = var.arm_application_key
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

# AWS iperf servers

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

resource "aws_vpn_gateway_attachment" "vpn_attachment" {
  provider = aws.region_1

  vpc_id         = module.aviatrix-create-transit-net-area-1.tvpc_id
  vpn_gateway_id = aws_vpn_gateway.vgw.id
}

resource "aws_dx_private_virtual_interface" "aws_vif" {
  count    = var.create_VIF ? 1 : 0
  provider = aws.region_1

  connection_id    = var.connection_id
  name             = var.vif_name
  vlan             = var.vlan
  address_family   = "ipv4"
  amazon_address   = var.amazon_address
  customer_address = var.customer_address
  bgp_asn          = var.bgp_asn
  mtu              = var.jumbo_frames ? 9001 : 1500
  bgp_auth_key     = "Aviatrix123#"
  vpn_gateway_id   = aws_vpn_gateway.vgw.id
}

# Azure
module "aviatrix-create-azure-transit-net-area-1" {
  source = "./azure_transit"

  region       = var.azure_region_1
  account_name = var.azure_account_name
  avtx_gw_size = var.azure_transit_gw_size # min "Standard_D3_v2" for HPE
  vnet_name    = var.azure_transit_name_1
  cidr         = var.azure_transit_cidr_1
  hpe          = true
  firenet      = false

  depends_on = [aviatrix_account.azure_account]
}

module "aviatrix-create-RFC1918-sg-area-1" {
  source = "./azure_RFC1918_sg"

  region        = var.azure_region_1
  ssh_addresses = var.ssh_addresses
}

module "aviatrix-create-avtx-vnets-area-1" {
  source = "./azure_vnets"

  region                     = var.azure_region_1
  account_name               = var.azure_account_name
  vnet_data                  = var.vnet_data_region_1
  native_peering             = false
  hpe                        = true
  avtx_gw_size               = var.azure_spoke_gw_size
  avx_transit_gw             = module.aviatrix-create-azure-transit-net-area-1.avtx_gw_name
  azure_subscription_id      = var.azure_subscription_id # needed to create VMS & attach security groups
  attach_rfc1918_sg          = true
  public_sg_id               = module.aviatrix-create-RFC1918-sg-area-1.public_sg_id
  private_sg_id              = module.aviatrix-create-RFC1918-sg-area-1.private_sg_id
  create_public_vm           = var.create_public_vm
  create_private_vm          = var.create_private_vm
  fixed_private_ip           = true
  private_ip                 = "10" # the last octet, module replaces xxx/xx in each subnet with this number
  enable_public_vm_password  = false
  enable_private_vm_password = true
  ubuntu_password            = var.ubuntu_password
  key_name                   = var.create_key ? tls_private_key.avtx_key[0].public_key_openssh : file("../cloudN_demo_pub.pem")
  custom_data                = data.template_file.ubuntu_server.template
}


# Azure ExpressRoute

resource "azurerm_express_route_circuit_peering" "er_peering" {
  count = var.create_peering ? 1 : 0

  peering_type                  = "AzurePrivatePeering"
  express_route_circuit_name    = data.terraform_remote_state.equinix.outputs.cloudN_1_er_circuit_name
  resource_group_name           = data.terraform_remote_state.equinix.outputs.cloudN_1_er_rg
  peer_asn                      = var.bgp_asn
  primary_peer_address_prefix   = var.azure_peer_prefix_pri
  secondary_peer_address_prefix = var.azure_peer_prefix_sec
  vlan_id                       = data.terraform_remote_state.equinix.outputs.cloudN_1_er_vlan_pri
}

resource "azurerm_virtual_network_gateway_connection" "vng_connection" {
  count = var.create_peering ? 1 : 0

  name                       = "cloudN-1"
  location                   = var.azure_region_1
  resource_group_name        = module.aviatrix-create-azure-transit-net-area-1.resource_group
  type                       = "ExpressRoute"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vng.id
  express_route_circuit_id   = data.terraform_remote_state.equinix.outputs.cloudN_1_er_circuit_id

  depends_on = [azurerm_express_route_circuit_peering.er_peering]
}

resource "azurerm_subnet" "vng_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = module.aviatrix-create-azure-transit-net-area-1.resource_group
  virtual_network_name = module.aviatrix-create-azure-transit-net-area-1.vnet_name
  address_prefixes     = [cidrsubnet(var.azure_transit_cidr_1, 4, 15)]
}

resource "azurerm_public_ip" "vng" {
  name                = "vng"
  location            = var.azure_region_1
  resource_group_name = module.aviatrix-create-azure-transit-net-area-1.resource_group
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "vng" {
  name                = "cloudN-vng"
  location            = var.azure_region_1
  resource_group_name = module.aviatrix-create-azure-transit-net-area-1.resource_group

  type     = "ExpressRoute"
  vpn_type = "RouteBased"
  sku      = "Standard" # try "High performance" for perf tests

  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.vng.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vng_gateway.id
  }
}

module "aviatrix-create-iperf-azure-vnet-1" {
  source = "./iperf_azure"

  instance_number            = var.azure_iperf_instance_number
  create_clients             = false
  servers_region             = var.azure_region_1
  instance_type              = var.azure_iperf_instance_type
  fixed_private_ip           = var.azure_iperf_fixed_private_ip
  private_ip                 = var.azure_iperf_private_ip
  enable_private_vm_password = true
  ubuntu_password            = var.ubuntu_password
  key_name                   = var.create_key ? tls_private_key.avtx_key[0].public_key_openssh : file("../cloudN_demo_pub.pem")
  servers_subnet_cidr_1      = module.aviatrix-create-avtx-vnets-area-1.private_subnets_cidr[0][0]
  servers_subnet_cidr_2      = module.aviatrix-create-avtx-vnets-area-1.private_subnets_cidr[0][1]
  servers_subnet_id_1        = module.aviatrix-create-avtx-vnets-area-1.private_subnets_id[0][0]
  servers_subnet_id_2        = module.aviatrix-create-avtx-vnets-area-1.private_subnets_id[0][1]
}

module "aviatrix-create-iperf-azure-vnet-2" {
  source = "./iperf_azure"

  instance_number            = var.azure_iperf_instance_number
  create_clients             = false
  servers_region             = var.azure_region_1
  instance_type              = var.azure_iperf_instance_type
  fixed_private_ip           = var.azure_iperf_fixed_private_ip
  private_ip                 = var.azure_iperf_private_ip
  enable_private_vm_password = true
  ubuntu_password            = var.ubuntu_password
  key_name                   = var.create_key ? tls_private_key.avtx_key[0].public_key_openssh : file("../cloudN_demo_pub.pem")
  servers_subnet_cidr_1      = module.aviatrix-create-avtx-vnets-area-1.private_subnets_cidr[1][0]
  servers_subnet_cidr_2      = module.aviatrix-create-avtx-vnets-area-1.private_subnets_cidr[1][1]
  servers_subnet_id_1        = module.aviatrix-create-avtx-vnets-area-1.private_subnets_id[1][0]
  servers_subnet_id_2        = module.aviatrix-create-avtx-vnets-area-1.private_subnets_id[1][1]
}

data "template_file" "ubuntu_server" {
  template = file("${path.cwd}/ubuntu_bootstrap")

  depends_on = [tls_private_key.avtx_key]
}

resource "tls_private_key" "avtx_key" {
  count = var.create_key ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 2048

  provisioner "local-exec" {
    command = "echo 'echo \"${tls_private_key.avtx_key[0].private_key_pem}\" > /home/ubuntu/.ssh/cloudN_demo.pem' | tee -a ./ubuntu_bootstrap ./iperf/iperf_client ./iperf/iperf_server"
  }

  provisioner "local-exec" {
    command = "echo 'chmod 400 /home/ubuntu/.ssh/cloudN_demo.pem' | tee -a ./ubuntu_bootstrap ./iperf/iperf_client ./iperf/iperf_server"
  }

  provisioner "local-exec" {
    command = "echo 'chown ubuntu /home/ubuntu/.ssh/cloudN_demo.pem' | tee -a ./ubuntu_bootstrap ./iperf/iperf_client ./iperf/iperf_server"
  }
}

resource "local_file" "avtx_priv_key" {
  count = var.create_key ? 1 : 0

  content         = tls_private_key.avtx_key[0].private_key_pem
  filename        = "./cloudN_demo_priv.pem"
  file_permission = "0400"
}

resource "local_file" "avtx_pub_key" {
  count = var.create_key ? 1 : 0

  content         = tls_private_key.avtx_key[0].public_key_openssh
  filename        = "./cloudN_demo_pub.pem"
  file_permission = "0666"
}

resource "aws_key_pair" "ec2_key" {
  count    = var.create_key ? 1 : 0
  provider = aws.region_1

  key_name   = var.key_name
  public_key = tls_private_key.avtx_key[0].public_key_openssh
}

resource "aws_key_pair" "ec2_key_imported" {
  count    = var.create_key ? 0 : 1
  provider = aws.region_1

  key_name   = var.key_name
  public_key = file("../cloudN_demo_pub.pem")
}
