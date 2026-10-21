locals {
  homelab_repo = abspath("${path.module}/../../../.")
  sops_file    = "${local.homelab_repo}/secrets/hcitest.enc.yaml"

  nodes = {
    hcitest01 = { ip = "172.16.0.21" }
    hcitest02 = { ip = "172.16.0.22" }
    hcitest03 = { ip = "172.16.0.23" }
  }

  storage_pool = "default"
}

# --- nixos-anywhere install ---
module "nixos-anywhere" {
  for_each = local.nodes

  source = "github.com/nix-community/nixos-anywhere/terraform/all-in-one?ref=1.13.0"

  nixos_system_attr      = "${local.homelab_repo}#nixosConfigurations.${each.key}.config.system.build.toplevel"
  nixos_partitioner_attr = "${local.homelab_repo}#nixosConfigurations.${each.key}.config.system.build.diskoScript"

  target_host = each.value.ip
  target_user = "root"
  instance_id = incus_instance.nodes[each.key].mac_address

  # env vars used by 'extra_files_script'
  extra_environment = {
    "NODE"      = each.key
    "SOPS_FILE" = local.sops_file
  }
  extra_files_script = "${path.module}/scripts/extra-files.sh"
}

# --- trunks bridge network ---
resource "incus_network" "trunks" {
  name = "hcitest-trunks"
  type = "bridge"

  config = {
    "ipv4.address" = "none"
    "ipv6.address" = "none"
    "dns.mode"     = "none"
    "bridge.mtu"   = "9000"
  }
}

# --- ceph osd volumes ---
resource "incus_storage_volume" "osd" {
  for_each = local.nodes

  name         = "${each.key}-osd"
  pool         = local.storage_pool
  content_type = "block"

  config = { size = "16GiB" }
}

# --- hcitest vms ---
resource "incus_instance" "nodes" {
  for_each = local.nodes

  name  = each.key
  image = var.image
  type  = "virtual-machine"

  config = {
    "limits.cpu"    = 2
    "limits.memory" = "4GiB"

    "security.secureboot" = false

    "cloud-init.user-data" = <<-EOT
      #cloud-config
      package_update: true
      packages: [openssh-server]
      disable_root: false
      users:
        - name: root
          lock_passwd: true
          ssh_authorized_keys: ${jsonencode(var.root_ssh_authkeys)}
    EOT
  }

  # root disk
  device {
    name = "root"
    type = "disk"
    properties = {
      path     = "/"
      pool     = local.storage_pool
      size     = "16GiB"
      "io.bus" = "nvme"
    }
  }

  # osd disk
  device {
    name = "osd"
    type = "disk"
    properties = {
      pool     = local.storage_pool
      source   = incus_storage_volume.osd[each.key].name
      "io.bus" = "nvme"
    }
  }

  # oob mgmt
  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = "incusbr0"
      "ipv4.address" = each.value.ip
    }
  }

  # data trunk
  device {
    name = "eth1"
    type = "nic"
    properties = {
      network       = incus_network.trunks.name
      "vlan.tagged" = "50"
    }
  }

  # storage trunk
  device {
    name = "eth2"
    type = "nic"
    properties = {
      network       = incus_network.trunks.name
      "vlan.tagged" = "40,41"
    }
  }

  wait_for {
    type = "cloud-init"
  }
}
