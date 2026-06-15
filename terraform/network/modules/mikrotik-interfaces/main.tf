# --- bridge ---

resource "routeros_interface_bridge" "bridge" {
  comment        = null
  name           = "bridge"
  vlan_filtering = true
}


# --- ethernets ---

resource "routeros_interface_ethernet" "interfaces" {
  for_each = var.interfaces

  comment      = each.value.comment
  disabled     = each.value.disabled
  factory_name = each.key
  name         = each.key
}


# --- bridge ports ---

locals {
  ifaces_frame_types = {
    for iface_k, iface_v in var.interfaces : iface_k => (
      iface_v.untagged != null && length(iface_v.tagged) == 0 ? "admit-only-untagged-and-priority-tagged" :
      iface_v.untagged == null && length(iface_v.tagged) > 0 ? "admit-only-vlan-tagged" :
      "admit-all"
    )
  }
}

resource "routeros_interface_bridge_port" "interfaces" {
  for_each = {
    for iface_k, iface_v in var.interfaces : iface_k => iface_v
    if iface_v.bridged
  }

  comment     = routeros_interface_ethernet.interfaces[each.key].comment
  disabled    = routeros_interface_ethernet.interfaces[each.key].disabled
  interface   = routeros_interface_ethernet.interfaces[each.key].name
  bridge      = routeros_interface_bridge.bridge.name
  pvid        = each.value.untagged != null ? var.vlans[each.value.untagged].id : null
  frame_types = local.ifaces_frame_types[each.key]
}


# --- bridge (l2) vlans ---

locals {
  vlans_iface_members = {
    for vlan_k, vlan_v in var.vlans : vlan_k => {
      tagged = [
        for iface_k, iface_v in var.interfaces : iface_k
        if contains(iface_v.tagged, vlan_k)
      ]
      untagged = [
        for iface_k, iface_v in var.interfaces : iface_k
        if iface_v.untagged == vlan_k
      ]
    }
  }
}

resource "routeros_interface_bridge_vlan" "vlans" {
  for_each = var.vlans

  comment  = coalesce(each.value.comment, each.key)
  bridge   = routeros_interface_bridge.bridge.name
  vlan_ids = [each.value.id]
  tagged = concat(
    [for iface in local.vlans_iface_members[each.key].tagged : routeros_interface_bridge_port.interfaces[iface].interface],
    each.value.svi != null ? [routeros_interface_bridge.bridge.name] : [],
  )
  untagged = [for iface in local.vlans_iface_members[each.key].untagged : routeros_interface_bridge_port.interfaces[iface].interface]
}


# --- interface (l3) vlans / svis ---

locals {
  svi_vlans = {
    for vlan_k, vlan_v in var.vlans : vlan_k => vlan_v
    if vlan_v.svi != null
  }
}

resource "routeros_interface_vlan" "svi_vlans" {
  for_each = local.svi_vlans

  comment   = coalesce(each.value.comment, each.key)
  name      = each.key
  interface = routeros_interface_bridge.bridge.name
  vlan_id   = each.value.id
}

resource "routeros_ip_address" "svi_vlans" {
  for_each = local.svi_vlans

  comment   = coalesce(each.value.comment, each.key)
  interface = routeros_interface_vlan.svi_vlans[each.key].name
  address   = each.value.svi
}