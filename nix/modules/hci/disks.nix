{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hci.disks;

  espPart = {
    type = "EF00";
    size = "1G";
    content = {
      type = "filesystem";
      format = "vfat";
      mountpoint = "/boot";
      mountOptions = [ "umask=0077" ];
    };
  };
  rootPart = {
    size = "100%";
    content = {
      type = "filesystem";
      format = "ext4";
      mountpoint = "/";
    };
  };
in
{
  options = {
    hci.disks = {
      osDisk = lib.mkOption {
        type = lib.types.strMatching "^/dev/disk/by-id/[^/]+$";
        example = "/dev/disk/by-id/<DISK IDENTIFIER>";
        description = "'by-id' path of disk used by 'disko' to wipe and partition for os install";
      };
    };
  };

  config = {
    disko.devices = {
      disk."system" = {
        type = "disk";
        device = cfg.osDisk;
        content = {
          type = "gpt";
          partitions."esp" = espPart;
          partitions."root" = rootPart;
        };
      };
    };
  };
}
