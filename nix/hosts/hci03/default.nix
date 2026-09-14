{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ../../modules/hci ];

  config = {
    # hardware configuration via nixos-facter
    hardware.facter.reportPath = ./hci03-facter.json;

    hci.disks.osDisk = "/dev/disk/by-path/pci-0000:58:00.0-nvme-1";
    hci.network.ipOctet = 13;
    hci.network.interfaces.dataTrunk = "pci-0000:02:00.0";
    hci.network.interfaces.storageTrunk = "pci-0000:02:00.1";
    hci.network.interfaces.oobMgmt = "pci-0000:59:00.0";

    # state version
    # see: https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "26.05";
  };
}
