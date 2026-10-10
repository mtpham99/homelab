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

  lvmPart = {
    size = "100%";
    content = {
      type = "lvm_pv";
      vg = "vg_main";
    };
  };
  rootLv = {
    size = cfg.rootLvSize;
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
      systemDisk = lib.mkOption {
        type = lib.types.strMatching "^/dev/disk/by-(id|uuid|path)/[^/]+$";
        example = "/dev/disk/by-id/<DISK IDENTIFIER>";
        description = "'by-<id | uuid | path>' path of disk used by 'disko' to wipe and partition for os/system install";
      };

      rootLvSize = lib.mkOption {
        type = lib.types.str;
        description = "size of lv used for '/'";
        default = "100%";
        example = "50%";
      };
    };
  };

  config = {
    disko.devices = {
      disk."system" = {
        type = "disk";
        device = cfg.systemDisk;
        content = {
          type = "gpt";
          partitions."esp" = espPart;
          partitions."lvm" = lvmPart;
        };
      };
      lvm_vg."vg_main" = {
        type = "lvm_vg";
        lvs."root" = rootLv;
      };
    };
  };
}
