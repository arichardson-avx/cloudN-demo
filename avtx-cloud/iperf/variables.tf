variable create_clients {
  default = true
}
variable clients_vpc {
  default = ""
}
variable clients_subnet_id_1 {
  default = ""
}
variable clients_subnet_id_2 {
  default = ""
}
variable clients_sg_id {
  default = ""
}

variable create_servers {
  default = true
}
variable servers_vpc {
  default = ""
}
variable servers_subnet_id_1 {
  default = ""
}
variable servers_subnet_id_2 {
  default = ""
}
variable servers_subnet_cidr_1 {
  default = ""
}
variable servers_subnet_cidr_2 {
  default = ""
}
variable servers_sg_id {
  default = ""
}

variable instance_type {
  default = "c5n.large"
}

variable ssh_addresses {
  type = list
}

variable key_name {}

variable ami {
  default = ""
}
variable instance_number {}
variable fixed_private_ip {
  default = false
}
variable private_ip_az_1 {
  default = ""
}

variable private_ip_az_2 {
  default = ""
}
