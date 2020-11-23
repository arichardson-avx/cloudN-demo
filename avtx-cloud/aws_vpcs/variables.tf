variable "region" {}

variable "account_name" {}

variable "vpc_data" {}

variable "tgw_vpc" {
  default     = false
  description = "Decides if VPC should be attached to a TGW"
}

variable "avx_transit_gw" {
  default = ""
}

variable "avtx_gw_size" {
  default = ""
}

variable "hpe" {
  default = false
}

variable avtx_gw_ha {
  default = true
}

variable "tgw_name" {
  default = ""
}

variable create_public_ec2 {
  default = true
}

variable create_private_ec2 {
  default = false
}

variable "key_name" {
  description = "Used for EC2s deployed inside VPCs"
  default     = ""
}

variable "ami" {
  default = ""
}

variable "user_data" {
  description = "Ubuntu commands to run at EC2 start"
  default     = ""
}

variable "instance_type" {
  default = "t3.micro"
}
variable "ssh_addresses" {
  description = "List of IP addresses allowed to access from the Internet"
  default     = []
}

variable "fixed_private_ip" {
  default = ""
}

variable "private_ip" {
  type        = string
  description = "the last octet, module replaces xxx/xx in the subnet with this number"
  default     = ""
}


