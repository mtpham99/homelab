# --- wireguard server ---

resource "routeros_interface_wireguard" "wg_server" {
  comment     = var.name
  name        = var.name
  listen_port = var.port
  private_key = var.private_key
}

resource "routeros_ip_address" "wg_server" {
  comment   = routeros_interface_wireguard.wg_server.comment
  interface = routeros_interface_wireguard.wg_server.name
  address   = "${cidrhost(var.subnet, 1)}/${split("/", var.subnet)[1]}"
}


# --- wireguard peers ---

resource "routeros_interface_wireguard_peer" "wg_peers" {
  for_each = var.peers

  comment         = "${each.key}-${routeros_interface_wireguard.wg_server.name}"
  name            = "${each.key}-${routeros_interface_wireguard.wg_server.name}"
  interface       = routeros_interface_wireguard.wg_server.name
  public_key      = each.value.public_key
  preshared_key   = each.value.preshared_key
  allowed_address = ["${each.value.peer_address}/32"]

  client_dns      = each.value.peer_dns
  client_address  = "${each.value.peer_address}/32"
  client_endpoint = var.endpoint
  # TODO: pr #987 https://github.com/terraform-routeros/terraform-provider-routeros/pull/987
  # client_allowed_address = each.value.peer_allowed_address

  is_responder = true
}
