output "vpcs" {
  value = aviatrix_vpc.aws_vpc
}

output "public_sg_ids" {
  value = values(aws_security_group.public)[*].id
}

output "vpc_ids" {
  value = values(aviatrix_vpc.aws_vpc)[*].vpc_id
}

output "public_subnet_ids" {
  value = values(aviatrix_vpc.aws_vpc)[*].public_subnets[*].subnet_id
}

output "public_subnet_cidrs" {
  value = values(aviatrix_vpc.aws_vpc)[*].public_subnets[*].cidr
}
