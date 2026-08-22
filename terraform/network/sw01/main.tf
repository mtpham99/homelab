# --- static routes ---

resource "routeros_ip_route" "gateway" {
  comment     = "gateway"
  dst_address = "0.0.0.0/0"
  gateway     = "10.137.10.1"
}


# --- mikrotik-interfaces ----

locals {
  vlans = {
    mgmt         = { id = 10, svi = "10.137.10.2/24" }
    ceph-cluster = { id = 40 }
    ceph-public  = { id = 41 }
    hosts        = { id = 50 }
  }

  trunk_vlans   = ["hosts"]
  storage_vlans = ["ceph-cluster", "ceph-public"]
  rtr01_vlans   = ["mgmt", "ceph-public", "hosts"]

  interfaces = {
    ether1 = {
      comment  = "mgmt"
      tagged   = []
      untagged = "mgmt"
    }

    sfp-sfpplus1 = {
      comment  = "hci01-trunk"
      tagged   = local.trunk_vlans
      untagged = null

      mtu   = 9000
      l2mtu = 9216
    }

    sfp-sfpplus2 = {
      comment  = "hci02-trunk"
      tagged   = local.trunk_vlans
      untagged = null

      mtu   = 9000
      l2mtu = 9216
    }

    sfp-sfpplus3 = {
      comment  = "hci03-trunk"
      tagged   = local.trunk_vlans
      untagged = null

      mtu   = 9000
      l2mtu = 9216
    }

    sfp-sfpplus4 = {
      comment  = "hci01-storage"
      tagged   = local.storage_vlans
      untagged = null

      mtu   = 9000
      l2mtu = 9216
    }

    sfp-sfpplus5 = {
      comment  = "hci02-storage"
      tagged   = local.storage_vlans
      untagged = null

      mtu   = 9000
      l2mtu = 9216
    }

    sfp-sfpplus6 = {
      comment  = "hci03-storage"
      tagged   = local.storage_vlans
      untagged = null

      mtu   = 9000
      l2mtu = 9216
    }

    sfp-sfpplus7 = {
      comment  = "rtr01-eth4-uplink"
      bridged  = false
      tagged   = local.rtr01_vlans
      untagged = null
    }

    sfp-sfpplus8 = {
      comment  = "rtr01-eth5-uplink"
      bridged  = false
      tagged   = local.rtr01_vlans
      untagged = null
    }
  }

  bonds = {
    "sfpp[7-8]" = {
      comment  = "rtr01-eth[4-5]-uplink"
      tagged   = local.rtr01_vlans
      untagged = null

      slaves               = ["sfp-sfpplus7", "sfp-sfpplus8"]
      mode                 = "802.3ad"
      transmit_hash_policy = "layer-3-and-4"
      lacp_rate            = "1sec"
    }
  }
}

module "interfaces" {
  source     = "../modules/mikrotik-interfaces"
  vlans      = local.vlans
  interfaces = local.interfaces
  bonds      = local.bonds
}
