provider "routeros" {
  hosturl        = var.routeros_hosturl
  username       = var.routeros_username
  password       = var.routeros_password
  insecure       = var.routeros_insecure
  ca_certificate = var.routeros_ca_certificate
}
