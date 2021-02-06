variable username {}
variable password {}
variable controller_ip {}

variable ssh_addresses {}

variable create_key {
  type = bool
}

variable key_name {
  type        = string
  description = "Key used to deploy EC2s"
}
