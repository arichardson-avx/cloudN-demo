variable aws_region_1 {}
variable aws_account_name {}
variable aws_profile {}
variable aws_transit_name_1 {}
variable aws_transit_cidr_1 {}
variable aws_transit_gw_size {}
variable aws_spoke_gw_size {}
variable vpc_data_region_1 {}

variable aws_iperf_instance_number {
  default = ""
}
variable aws_iperf_instance_type {
  default = ""
}

variable create_public_ec2 {
  default = true
}

variable create_private_ec2 {
  default = true
}

variable create_VIF {}
variable connection_id {}
variable aws_vlan {}
variable vif_name {}
variable amazon_address {}
variable amazon_side_asn {}
variable customer_address {}
variable bgp_asn {}
variable jumbo_frames {
  type = bool
}

