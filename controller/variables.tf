variable "region" {}

variable "profile" {
  type    = string
  default = "default"
}

variable "vpc_name" {}

variable "subnet_zone" {}

variable "create_key" {
  type = bool
}

variable "keypair" {}

variable "name_prefix" {
  type        = string
  description = "Use if deploying second controller in given account"
}

variable "license_type" {}

variable "access_account_name" {}

variable "admin_email" {}

variable "admin_password" {}

variable "customer_license_id" {
  default = ""
}

variable "ec2role" {
  default = ""
}

variable "ssh_addresses" {
  type    = list
  default = []
}

