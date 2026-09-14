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
    hardware.facter.reportPath = ./hci01-facter.json;

    hci.disks.osDisk = "/dev/disk/by-path/pci-0000:58:00.0-nvme-1";

    # state version
    # see: https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "26.05";
  };
}
