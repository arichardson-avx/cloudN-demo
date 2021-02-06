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
  ssh_addresses = ["0.0.0.0/0"]
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

resource "azurerm_resource_group" "cloudN_demo" {
  name     = "cloudN-demo"
  location = "West US"
}

resource "azurerm_express_route_circuit" "cloudN_demo" {
  name                  = "cloudN-demo-ExpressRoute"
  resource_group_name   = azurerm_resource_group.cloudN_demo.name
  location              = azurerm_resource_group.cloudN_demo.location
  service_provider_name = "Equinix"
  peering_location      = "Silicon Valley"
  bandwidth_in_mbps     = 10000
  sku {
    tier   = "Standard"
    family = "MeteredData"
  }
  allow_classic_operations = false
}

resource "azurerm_express_route_circuit_peering" "er_peering" {
  count = var.create_peering ? 1 : 0

  peering_type                  = "AzurePrivatePeering"
  express_route_circuit_name    = azurerm_express_route_circuit.cloudN_demo.name
  resource_group_name           = azurerm_resource_group.cloudN_demo.name
  peer_asn                      = var.bgp_asn
  primary_peer_address_prefix   = var.azure_peer_prefix_pri
  secondary_peer_address_prefix = var.azure_peer_prefix_sec
  vlan_id                       = var.azure_vlan
}

module "aviatrix-create-vng" {
  source = "./azure_vng"

  location                 = var.azure_region_1
  resource_group_name      = module.aviatrix-create-azure-transit-net-area-1.resource_group
  virtual_network_name     = module.aviatrix-create-azure-transit-net-area-1.vnet_name
  address_prefixes         = [cidrsubnet(var.azure_transit_cidr_1, 4, 15)]
  sku                      = "UltraPerformance"
  express_route_circuit_id = azurerm_express_route_circuit.cloudN_demo.id
  connect_vng              = var.create_peering


  depends_on = [azurerm_express_route_circuit_peering.er_peering]
}

module "aviatrix-create-iperf-azure-vnet-1" {
  source = "./iperf_azure"

  instance_number            = var.azure_iperf_instance_number
  create_clients             = false
  servers_region             = var.azure_region_1
  instance_type              = var.azure_iperf_instance_type
  fixed_private_ip           = var.azure_iperf_fixed_private_ip
  private_ip                 = var.azure_iperf_private_ip
  enable_private_vm_password = false
  ubuntu_password            = var.ubuntu_password
  key_name                   = var.create_key ? tls_private_key.avtx_key[0].public_key_openssh : file("../cloudN_demo_pub.pem")
  servers_subnet_cidr_1      = module.aviatrix-create-avtx-vnets-area-1.public_subnets_cidr[0][1]
  servers_subnet_cidr_2      = module.aviatrix-create-avtx-vnets-area-1.public_subnets_cidr[0][2]
  servers_subnet_id_1        = module.aviatrix-create-avtx-vnets-area-1.public_subnets_id[0][1]
  servers_subnet_id_2        = module.aviatrix-create-avtx-vnets-area-1.public_subnets_id[0][2]
}

module "aviatrix-create-iperf-azure-vnet-2" {
  source = "./iperf_azure"

  instance_number            = var.azure_iperf_instance_number
  create_clients             = false
  servers_region             = var.azure_region_1
  instance_type              = var.azure_iperf_instance_type
  fixed_private_ip           = var.azure_iperf_fixed_private_ip
  private_ip                 = var.azure_iperf_private_ip
  enable_private_vm_password = false
  ubuntu_password            = var.ubuntu_password
  key_name                   = var.create_key ? tls_private_key.avtx_key[0].public_key_openssh : file("../cloudN_demo_pub.pem")
  servers_subnet_cidr_1      = module.aviatrix-create-avtx-vnets-area-1.public_subnets_cidr[1][1]
  servers_subnet_cidr_2      = module.aviatrix-create-avtx-vnets-area-1.public_subnets_cidr[1][2]
  servers_subnet_id_1        = module.aviatrix-create-avtx-vnets-area-1.public_subnets_id[1][1]
  servers_subnet_id_2        = module.aviatrix-create-avtx-vnets-area-1.public_subnets_id[1][2]
}
