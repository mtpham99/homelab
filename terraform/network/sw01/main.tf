locals {
  vlans = {
    mgmt    = { id = 10, svi = "10.137.10.2/24" }
    storage = { id = 40 }
    servers = { id = 50 }
    trusted = { id = 100 }
    guest   = { id = 200 }
  }

  interfaces = {
    ether1 = {
      comment  = "mgmt"
      tagged   = []
      untagged = "mgmt"
    }

    sfp-sfpplus1 = {
      comment  = "reserved-hci01-trunk"
      tagged   = [for vlan_k, vlan_v in local.vlans : vlan_k]
      untagged = null
    }

    sfp-sfpplus2 = {
      comment  = "reserved-hci02-trunk"
      tagged   = [for vlan_k, vlan_v in local.vlans : vlan_k]
      untagged = null
    }

    sfp-sfpplus3 = {
      comment  = "reserved-hci03-trunk"
      tagged   = [for vlan_k, vlan_v in local.vlans : vlan_k]
      untagged = null
    }

    sfp-sfpplus4 = {
      comment  = "reserved-hci01-storage"
      tagged   = []
      untagged = "storage"
    }

    sfp-sfpplus5 = {
      comment  = "reserved-hci02-storage"
      tagged   = []
      untagged = "storage"
    }

    sfp-sfpplus6 = {
      comment  = "reserved-hci03-storage"
      tagged   = []
      untagged = "storage"
    }

    sfp-sfpplus7 = {
      comment  = "inactive"
      disabled = true
      tagged   = []
      untagged = null
    }

    sfp-sfpplus8 = {
      comment  = "rtr01-uplink"
      tagged   = [for vlan_k, vlan_v in local.vlans : vlan_k]
      untagged = null
    }
  }
}

module "interfaces" {
  source     = "../modules/mikrotik-interfaces"
  vlans      = local.vlans
  interfaces = local.interfaces
}