terraform {
  required_providers {
    aviatrix = {
      source           = "aviatrixsystems/aviatrix"
      required_version = "~> 2.17.0"
    }
    template = {
      source           = "hashicorp/template"
      required_version = "~> 2.2.0"
    }
    azurerm = {
      source           = "hashicorp/azurerm"
      required_version = "~> 2.44.0"
    }
  }
  required_version = ">= 0.13"
}
