variable "region" {}

variable "account_name" {}

variable "vnet_data" {
  type = map(object({
    name = string
    cidr = string
  }))
}

variable "avx_transit_gw" {}

variable "avtx_gw_size" {}

variable "hpe" {
  default = false
}

variable "avtx_gw_ha" {
  default = true
}

variable "native_peering" {
  default = false
}

variable "azure_subscription_id" {
  default = ""
}

variable "instance_type" {
  default = "Standard_B2s"
}

variable "key_name" {
  default = ""
}

variable "enable_public_vm_password" {
  default = ""
}

variable "enable_private_vm_password" {
  default = ""
}

variable "ubuntu_password" {
  default = ""
}

variable "fixed_private_ip" {
  default = false
}

variable "private_ip" {
  type        = string
  description = "the last octet, module replaces xxx/xx in the subnet with this number"
  default     = ""
}

variable "create_public_vm" {
  default = false
}

variable "create_private_vm" {
  default = false
}

variable "custom_data" {
  default = ""
}

variable "attach_rfc1918_sg" {
  default = false
}

variable "public_sg_id" {
  default = ""
}

variable "private_sg_id" {
  default = ""
}