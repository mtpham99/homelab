{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/hci
    ../hcitest-cluster.nix
  ];

  config = {
    # hardware configuration via nixos-facter
    hardware.facter.reportPath = ./hcitest02-facter.json;

    # secrets file
    hci.secrets.sopsFile = ../../../secrets/hcitest.enc.yaml;

    # hci configs
    hci.disks.systemDisk = "/dev/disk/by-path/pci-0000:08:00.0-nvme-1";
    hci.disks.rootLvSize = "50%";
    hci.network.interfaces.dataTrunk = "pci-0000:06:00.0";
    hci.network.interfaces.storageTrunk = "pci-0000:07:00.0";
    hci.network.interfaces.oobMgmt = "pci-0000:05:00.0";

    # hcitest[0x] quirks: enable incus agent for monitoring/management
    virtualisation.incus.agent.enable = true;

    # hcitest[0x] quirks: configure console for `incus console ...`
    boot.kernelParams = [
      "console=tty0"
      "console=ttyS0,115200"
    ];

    # hcitest[0x] quirks: use oob mgmt nic on `incusbr0` instead of vlan50 on data trunk for portability
    systemd.network.networks."10-oob-mgmt".networkConfig.DHCP = lib.mkForce "ipv4";
    systemd.network.networks."50-vlan50" = {
      gateway = lib.mkForce [ ];
      dns = lib.mkForce [ ];
    };

    # state version
    # see: https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "26.11";
  };
}
