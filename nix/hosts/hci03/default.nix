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

    hci.disks.osDisk = "/dev/disk/by-id/nvme-WDS100T1X0E-00AFY0_211620801340";

    # state version
    # see: https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "26.05";
  };
}
