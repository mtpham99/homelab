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
    # hardware.facter.reportPath = ./hci03-facter.json;

    # state version
    # see: https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "26.05";
  };
}
