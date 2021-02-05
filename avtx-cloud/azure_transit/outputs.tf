output "tvpc_id" {
  value = aviatrix_vpc.azure_transit.vpc_id
}

output "resource_group" {
  value = aviatrix_vpc.azure_transit.resource_group
}

output "vnet_name" {
  value = aviatrix_vpc.azure_transit.name
}

output "avtx_gw_name" {
  value = aviatrix_transit_gateway.transit_gateway_tvpc.gw_name
}

output "transit_gw_public_ip" {
  value = aviatrix_transit_gateway.transit_gateway_tvpc.eip
}

output "transit_gw_private_ip" {
  value = aviatrix_transit_gateway.transit_gateway_tvpc.private_ip
}

output "transit_hagw_public_ip" {
  value = aviatrix_transit_gateway.transit_gateway_tvpc.ha_eip
}

output "tvpc_cidr" {
  value = aviatrix_vpc.azure_transit.cidr
}

output "firenet_mgmt_subnet" {
  value = aviatrix_vpc.azure_transit.subnets[2].cidr
}

output "firenet_mgmt_subnet_ha" {
  value = aviatrix_vpc.azure_transit.subnets[3].cidr
}

output "firenet_egress_subnet" {
  value = aviatrix_vpc.azure_transit.subnets[0].cidr
}

output "firenet_egress_subnet_ha" {
  value = aviatrix_vpc.azure_transit.subnets[1].cidr
}
