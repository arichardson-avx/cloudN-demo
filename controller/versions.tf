terraform {
  required_providers {
    aviatrix = {
      source           = "aviatrixsystems/aviatrix"
      required_version = "~> 2.17.0"
    }
    aws = {
      source           = "hashicorp/aws"
      required_version = "~> 3.15.0"
    }
    local = {
      source           = "hashicorp/local"
      required_version = "~> 2.0.0"
    }
    tls = {
      source           = "hashicorp/tls"
      required_version = "~> 3.0.0"
    }
  }
  required_version = ">= 0.13"
}
