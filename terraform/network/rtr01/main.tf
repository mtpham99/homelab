# --- mikrotik interfaces ---

locals {
  vlans = {
    mgmt        = { id = 10, svi = "10.137.10.1/24" }
    ceph-public = { id = 41, svi = "10.137.41.1/24" }
    hosts       = { id = 50, svi = "10.137.50.1/24" }
    home        = { id = 100, svi = "10.137.100.1/24" }
    guest       = { id = 200, svi = "10.137.200.1/24" }
  }

  sw01_vlans = ["mgmt", "ceph-public", "hosts"]

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
      comment  = "fs105-eth5-uplink"
      tagged   = []
      untagged = "mgmt"
    }

    ether4 = {
      comment  = "sw01-sfpp7-uplink"
      bridged  = false
      tagged   = local.sw01_vlans
      untagged = null
    }

    ether5 = {
      comment  = "sw01-sfpp8-uplink"
      bridged  = false
      tagged   = local.sw01_vlans
      untagged = null
    }
  }

  bonds = {
    "eth[4-5]" = {
      comment  = "sw01-sfpp[7-8]-uplink"
      tagged   = local.sw01_vlans
      untagged = null

      slaves               = ["ether4", "ether5"]
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


# --- mikrotik-wireguard ---

data "sops_file" "wg_info" {
  source_file = "${path.module}/../../../secrets/wireguard.enc.yaml"
}

module "wireguard" {
  source      = "../modules/mikrotik-wireguard"
  name        = "murkymirror-mgmt"
  subnet      = "10.137.210.0/24"
  port        = yamldecode(data.sops_file.wg_info.raw).wg_murkymirror_mgmt.port
  endpoint    = yamldecode(data.sops_file.wg_info.raw).wg_murkymirror_mgmt.endpoint
  private_key = yamldecode(data.sops_file.wg_info.raw).wg_murkymirror_mgmt.sk

  peers = {
    grunfeld = {
      peer_address  = "10.137.210.11"
      peer_dns      = "10.137.210.1"
      public_key    = yamldecode(data.sops_file.wg_info.raw).wg_murkymirror_mgmt.peers.grunfeld.pk
      preshared_key = yamldecode(data.sops_file.wg_info.raw).wg_murkymirror_mgmt.peers.grunfeld.psk
    }
    mobile = {
      peer_address  = "10.137.210.21"
      peer_dns      = "10.137.210.1"
      public_key    = yamldecode(data.sops_file.wg_info.raw).wg_murkymirror_mgmt.peers.mobile.pk
      preshared_key = yamldecode(data.sops_file.wg_info.raw).wg_murkymirror_mgmt.peers.mobile.psk
    }
  }
}

module "wireguard-stellarspire" {
  source      = "../modules/mikrotik-wireguard"
  name        = "stellarspire-sscs"
  subnet      = "10.137.240.0/27"
  port        = yamldecode(data.sops_file.wg_info.raw).wg_stellarspire_sscs.port
  endpoint    = yamldecode(data.sops_file.wg_info.raw).wg_stellarspire_sscs.endpoint
  private_key = yamldecode(data.sops_file.wg_info.raw).wg_stellarspire_sscs.sk

  peers = {
    meridianprime = {
      peer_address  = "10.137.240.11"
      peer_dns      = "10.137.240.1"
      public_key    = yamldecode(data.sops_file.wg_info.raw).wg_stellarspire_sscs.peers.meridianprime.pk
      preshared_key = yamldecode(data.sops_file.wg_info.raw).wg_stellarspire_sscs.peers.meridianprime.psk
    }
    sscs35782 = {
      peer_address  = "10.137.240.21"
      peer_dns      = "10.137.240.1"
      public_key    = yamldecode(data.sops_file.wg_info.raw).wg_stellarspire_sscs.peers.sscs35782.pk
      preshared_key = yamldecode(data.sops_file.wg_info.raw).wg_stellarspire_sscs.peers.sscs35782.psk
    }
  }
}
