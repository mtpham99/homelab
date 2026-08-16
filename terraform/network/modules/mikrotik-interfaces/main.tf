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


# --- bonding ---

resource "routeros_interface_bonding" "bonds" {
  for_each = var.bonds

  comment  = each.value.comment
  disabled = each.value.disabled
  name     = each.key

  slaves = each.value.slaves
  mode   = each.value.mode

  mtu                  = each.value.mtu
  transmit_hash_policy = each.value.transmit_hash_policy
  lacp_rate            = each.value.lacp_rate
}


# --- bridge ports ---

locals {
  all_bond_slaves = flatten([for bond in var.bonds : bond.slaves])
  bridge_ports = merge(
    {
      for iface_k, iface_v in var.interfaces : iface_k => merge(
        {
          type = "iface"
          frame_type = (
            iface_v.untagged != null && length(iface_v.tagged) == 0 ? "admit-only-untagged-and-priority-tagged" :
            iface_v.untagged == null && length(iface_v.tagged) > 0 ? "admit-only-vlan-tagged" :
            "admit-all"
          )
        },
        iface_v
      )
      if iface_v.bridged && !contains(local.all_bond_slaves, iface_k)
    },
    {
      for bond_k, bond_v in var.bonds : bond_k => merge(
        {
          type = "bond"
          frame_type = (
            bond_v.untagged != null && length(bond_v.tagged) == 0 ? "admit-only-untagged-and-priority-tagged" :
            bond_v.untagged == null && length(bond_v.tagged) > 0 ? "admit-only-vlan-tagged" :
            "admit-all"
          )
        },
        bond_v
      )
      if bond_v.bridged
    }
  )
}

resource "routeros_interface_bridge_port" "interfaces" {
  for_each = {
    for port_k, port_v in local.bridge_ports : port_k => port_v
    if port_v.type == "iface"
  }

  comment     = routeros_interface_ethernet.interfaces[each.key].comment
  disabled    = routeros_interface_ethernet.interfaces[each.key].disabled
  interface   = routeros_interface_ethernet.interfaces[each.key].name
  bridge      = routeros_interface_bridge.bridge.name
  pvid        = each.value.untagged != null ? var.vlans[each.value.untagged].id : 1
  frame_types = each.value.frame_type
}

resource "routeros_interface_bridge_port" "bonds" {
  for_each = {
    for port_k, port_v in local.bridge_ports : port_k => port_v
    if port_v.type == "bond"
  }

  comment     = routeros_interface_bonding.bonds[each.key].comment
  disabled    = routeros_interface_bonding.bonds[each.key].disabled
  interface   = routeros_interface_bonding.bonds[each.key].name
  bridge      = routeros_interface_bridge.bridge.name
  pvid        = each.value.untagged != null ? var.vlans[each.value.untagged].id : 1
  frame_types = each.value.frame_type
}


# --- bridge (l2) vlans ---

locals {
  vlans_port_members = {
    for vlan_k, vlan_v in var.vlans : vlan_k => {
      tagged = [
        for port_k, port_v in local.bridge_ports : port_k
        if contains(port_v.tagged, vlan_k)
      ]
      untagged = [
        for port_k, port_v in local.bridge_ports : port_k
        if port_v.untagged == vlan_k
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
    each.value.svi != null ? [routeros_interface_bridge.bridge.name] : [],
    [
      for port in local.vlans_port_members[each.key].tagged : (
        local.bridge_ports[port].type == "iface"
        ? routeros_interface_bridge_port.interfaces[port].interface
        : routeros_interface_bridge_port.bonds[port].interface
      )
    ]
  )
  untagged = [
    for port in local.vlans_port_members[each.key].untagged : (
      local.bridge_ports[port].type == "iface"
      ? routeros_interface_bridge_port.interfaces[port].interface
      : routeros_interface_bridge_port.bonds[port].interface
    )
  ]
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
