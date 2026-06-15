locals {
  vlans = {
    mgmt    = { id = 10, svi = "10.137.10.1/24" }
    storage = { id = 40, svi = "10.137.40.1/24" }
    servers = { id = 50, svi = "10.137.50.1/24" }
    trusted = { id = 100, svi = "10.137.100.1/24" }
    guest   = { id = 200, svi = "10.137.200.1/24" }
  }

  interfaces = {
    ether1 = {
      comment  = "isp-uplink"
      bridged  = false
      tagged   = []
      untagged = null
    }

    ether2 = {
      comment  = "mgmt"
      tagged   = []
      untagged = "mgmt"
    }

    ether3 = {
      comment  = "fs105-uplink-mgmt"
      tagged   = []
      untagged = "mgmt"
    }

    ether4 = {
      comment  = "inactive"
      disabled = true
      tagged   = []
      untagged = null
    }

    ether5 = {
      comment  = "sw01-uplink"
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
