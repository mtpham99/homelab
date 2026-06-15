# --- bridge ---

output "bridge" {
  description = "bridge resource"
  value       = routeros_interface_bridge.bridge
}


# --- ethernets ---

output "ethernets" {
  description = "ethernet resources"
  value       = routeros_interface_ethernet.interfaces
}


# --- svi addresses ---

output "svi_addresses" {
  description = "svi address resources"
  value       = routeros_ip_address.svi_vlans
}