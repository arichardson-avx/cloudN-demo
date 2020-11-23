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
    template = {
      source           = "hashicorp/template"
      required_version = "~> 2.2.0"
    }
  }
  required_version = ">= 0.13"
}
