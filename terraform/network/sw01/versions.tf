terraform {
  required_version = ">= 1.5"

  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "~> 1.99"
    }

    sops = {
      source  = "carlpett/sops"
      version = "~> 1.3"
    }
  }
}
