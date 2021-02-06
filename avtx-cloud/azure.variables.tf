variable azure_region_1 {}
variable azure_account_name {}
variable azure_subscription_id {}
variable arm_directory_id {}
variable arm_application_id {}
variable arm_application_key {}
variable azure_transit_name_1 {}
variable azure_transit_cidr_1 {}
variable azure_transit_gw_size {}
variable azure_spoke_gw_size {}
variable vnet_data_region_1 {}
variable ubuntu_password {}
variable create_public_vm {
  default = true
}
variable create_private_vm {
  default = true
}
variable "create_peering" {
  type = bool
}
variable azure_peer_prefix_pri {}
variable azure_peer_prefix_sec {}
variable azure_vlan {}

variable azure_iperf_instance_number {
  default = ""
}
variable azure_iperf_instance_type {
  default = ""
}
variable azure_iperf_fixed_private_ip {
  default = ""
}
variable azure_iperf_private_ip {
  default = ""
}
