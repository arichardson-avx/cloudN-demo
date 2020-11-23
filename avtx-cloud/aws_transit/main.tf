
resource "aviatrix_vpc" "aws_transit" {
  cloud_type           = 1
  account_name         = var.account_name
  region               = var.region
  name                 = var.aws_transit_name
  cidr                 = var.cidr
  aviatrix_transit_vpc = var.firenet ? false : true
  aviatrix_firenet_vpc = var.firenet ? true : false
}

resource "aviatrix_transit_gateway" "transit_gateway_tvpc" {
  cloud_type                    = 1
  vpc_reg                       = var.region
  vpc_id                        = aviatrix_vpc.aws_transit.vpc_id
  account_name                  = aviatrix_vpc.aws_transit.account_name
  gw_name                       = "atgw-aws-${var.region}"
  insane_mode                   = var.hpe
  gw_size                       = var.avtx_gw_size
  ha_gw_size                    = var.avtx_gw_ha ? var.avtx_gw_size : null
  subnet                        = var.hpe ? cidrsubnet(aviatrix_vpc.aws_transit.cidr, 4, 4) : aviatrix_vpc.aws_transit.subnets[4].cidr
  ha_subnet                     = var.avtx_gw_ha ? (var.hpe ? cidrsubnet(aviatrix_vpc.aws_transit.cidr, 4, 8) : aviatrix_vpc.aws_transit.subnets[6].cidr) : null
  insane_mode_az                = var.hpe ? data.aws_subnet.gw_az.availability_zone : null
  ha_insane_mode_az             = var.avtx_gw_ha ? (var.hpe ? data.aws_subnet.hagw_az.availability_zone : null) : null
  enable_active_mesh            = true
  enable_hybrid_connection      = true
  connected_transit             = true
  bgp_ecmp                      = true
  enable_advertise_transit_cidr = false
  enable_transit_firenet        = var.firenet
}

data "aws_subnet" "gw_az" {
  id = aviatrix_vpc.aws_transit.subnets[0].subnet_id
}

data "aws_subnet" "hagw_az" {
  id = aviatrix_vpc.aws_transit.subnets[2].subnet_id
}

