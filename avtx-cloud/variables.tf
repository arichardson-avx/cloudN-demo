variable username {}
variable password {}
variable controller_ip {}

variable aws_region_1 {}
variable aws_account_name {}
variable aws_profile {}
variable aws_transit_name_1 {}
variable aws_transit_cidr_1 {}
variable aws_transit_gw_size {}
variable aws_spoke_gw_size {}
variable vpc_data_region_1 {}

variable ssh_addresses {}

variable create_key {
  type = bool
}

variable key_name {
  type        = string
  description = "Key used to deploy EC2s"
}

variable aws_iperf_instance_number {
  default = ""
}
variable aws_iperf_instance_type {
  default = ""
}
variable aws_iperf_fixed_private_ip {
  default = ""
}
variable aws_iperf_private_ip {
  default = ""
}
variable iperf_clients_vpc_1 {
  default = ""
}
variable iperf_servers_vpc_1 {
  default = ""
}
variable iperf_clients_vpc_2 {
  default = ""
}
variable iperf_servers_vpc_2 {
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
variable vif_name {}
variable vlan {}
variable amazon_address {}
variable amazon_side_asn {}
variable customer_address {}
variable bgp_asn {}
variable jumbo_frames {
  type = bool
}

