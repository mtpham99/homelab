{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hci.base;

  ipv4Option =
    description:
    lib.mkOption {
      type = lib.types.strMatching "^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$";
      inherit description;
      example = "192.168.0.1/24";
    };
in
{
  options = {
    hci.base = {
      cluster = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options.ipv4 = {
              host = ipv4Option "ipv4 address on host (in-band) mgmt network";
              cephCluster = ipv4Option "ipv4 address on ceph cluster network";
              cephPublic = ipv4Option "ipv4 address on ceph public network";
              oobMgmt = ipv4Option "ipv4 address on oob (out-of-band) mgmt network";
            };
          }
        );
        description = "cluster definition attrset";
        example = {
          "node01" = {
            ipv4.host = "192.168.1.11/24";
            ipv4.cephCluster = "192.168.2.11/24";
            ipv4.cephPublic = "192.168.3.11/24";
            ipv4.oobMgmt = "192.168.0.11/24";
          };
          "node02" = {
            ipv4.host = "192.168.1.12/24";
            ipv4.cephCluster = "192.168.2.12/24";
            ipv4.cephPublic = "192.168.3.12/24";
            ipv4.oobMgmt = "192.168.0.12/24";
          };
          "node03".ipv4 = {
            ipv4.host = "192.168.1.13/24";
            ipv4.cephCluster = "192.168.2.13/24";
            ipv4.cephPublic = "192.168.3.13/24";
            ipv4.oobMgmt = "192.168.0.13/24";
          };
        };
      };
    };
  };

  config = {
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 10;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages = pkgs.linuxPackages; # default is lts
    boot.kernelModules = [ ];
    boot.kernelParams = [ ];
    # boot.extraModprobeConfig = ''
    #
    # '';

    hardware.facter.detected.graphics.enable = false;
    hardware.facter.detected.bluetooth.enable = false;

    time.timeZone = "UTC";
    i18n.defaultLocale = "en_US.UTF-8";

    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users = [
          "root"
          "@wheel"
        ];
      };
      settings.flake-registry = "";
      channel.enable = false;

      gc = {
        automatic = true;
        dates = "monthly";
        options = "--delete-older-than 90d";
      };
      settings.auto-optimise-store = true;
    };

    users.mutableUsers = false;
    users.groups."hci-admin".gid = 1000;
    users.users = {
      "root".hashedPasswordFile = config.sops.secrets."hci_admin_password_hash".path;

      "hci-admin" = {
        uid = 1000;
        description = "hci cluster admin";
        isNormalUser = true;
        group = "hci-admin";
        extraGroups = [ "wheel" ];
        hashedPasswordFile = config.sops.secrets."hci_admin_password_hash".path;
      };
    };
    systemd.tmpfiles.rules =
      let
        normalUsers = lib.filterAttrs (_: user: user.isNormalUser) config.users.users;
      in
      lib.mapAttrsToList (_: user: "d ${user.home}/.ssh 0700 ${user.name} ${user.group} -") normalUsers;

    security.sudo.wheelNeedsPassword = true;
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
      hostKeys = [
        {
          path = config.sops.secrets."ssh_host_ed25519_key".path;
          type = "ed25519";
        }
      ];
    };
  };
}
