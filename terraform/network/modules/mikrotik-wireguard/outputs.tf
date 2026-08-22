# --- wireguard server ---

output "interface" {
  description = "wireguard interface resource"
  value       = routeros_interface_wireguard.wg_server
  sensitive   = true
}

output "pubkey" {
  description = "wireguard server's public key"
  value       = routeros_interface_wireguard.wg_server.public_key
}

output "endpoint" {
  description = "wireguard server's wan endpoint peers connect to"
  value       = "${var.endpoint}:${var.port}"
}

output "address" {
  description = "wireguard server's tunnel address"
  value       = routeros_ip_address.wg_server.address
}


# --- wireguard peers ---

output "peers" {
  description = "wireguard peer resources"
  value       = routeros_interface_wireguard_peer.wg_peers
  sensitive   = true
}