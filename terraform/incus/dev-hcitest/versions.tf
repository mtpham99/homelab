terraform {
  required_version = ">= 1.5"

  required_providers {
    incus = {
      source  = "lxc/incus"
      version = "~> 1.2"
    }
  }
}
