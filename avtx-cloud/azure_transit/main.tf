
resource "aviatrix_vpc" "azure_transit" {
  cloud_type           = 8
  account_name         = var.account_name
  region               = var.region
  name                 = var.vnet_name
  cidr                 = var.cidr
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = true
}

resource "aviatrix_transit_gateway" "transit_gateway_tvpc" {
  cloud_type             = 8
  vpc_reg                = var.region
  vpc_id                 = aviatrix_vpc.azure_transit.vpc_id
  account_name           = aviatrix_vpc.azure_transit.account_name
  gw_name                = "atgw-azure-${replace(lower(var.region), " ", "-")}"
  insane_mode            = var.hpe
  gw_size                = var.avtx_gw_size                         # min "Standard_D3_v2" for HPE
  ha_gw_size             = var.avtx_gw_ha ? var.avtx_gw_size : null # min "Standard_D3_v2" for HPE
  subnet                 = var.hpe ? cidrsubnet(aviatrix_vpc.azure_transit.cidr, 4, 4) : aviatrix_vpc.azure_transit.subnets[2].cidr
  ha_subnet              = var.avtx_gw_ha ? (var.hpe ? cidrsubnet(aviatrix_vpc.azure_transit.cidr, 4, 8) : aviatrix_vpc.azure_transit.subnets[3].cidr) : null
  enable_active_mesh     = true
  connected_transit      = true
  bgp_ecmp               = true
  enable_transit_firenet = var.firenet
}

