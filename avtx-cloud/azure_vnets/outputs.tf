output "vnet_ids" {
  value = values(aviatrix_vpc.azure_vnet)[*].vpc_id
}

output "private_subnets_cidr" {
  value = values(aviatrix_vpc.azure_vnet)[*].private_subnets[*].cidr
}

output "public_subnets_cidr" {
  value = values(aviatrix_vpc.azure_vnet)[*].public_subnets[*].cidr
}

output "private_subnets_id" {
  value = values(aviatrix_vpc.azure_vnet)[*].private_subnets[*].subnet_id
}

output "public_subnets_id" {
  value = values(aviatrix_vpc.azure_vnet)[*].public_subnets[*].subnet_id
}

/*
output "vnets" {
  value = aviatrix_vpc.azure_vnet
}

output "public_sg_ids" {
  value = values(aws_security_group.public)[*].id
}

output "subnets_id" {
  value = values(aviatrix_vpc.azure_vnet)[*].subnets[*].subnet_id
}
*/


