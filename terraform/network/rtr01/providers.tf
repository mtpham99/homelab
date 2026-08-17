ephemeral "sops_file" "creds" {
  source_file = "${path.module}/../../../secrets/mikrotik.yaml"
}

provider "routeros" {
  hosturl        = var.routeros_hosturl
  username       = ephemeral.sops_file.creds.data["mikrotik_cicd_username"]
  password       = ephemeral.sops_file.creds.data["mikrotik_cicd_password"]
  insecure       = var.routeros_insecure
  ca_certificate = var.routeros_ca_certificate
}
