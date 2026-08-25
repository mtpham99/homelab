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
    hardware.facter.reportPath = ./hci02-facter.json;

    hci.disks.osDisk = "/dev/disk/by-id/nvme-WDS100T1X0E-00AFY0_21173R805693";

    # state version
    # see: https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "26.05";
  };
}
