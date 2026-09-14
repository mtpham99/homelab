{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hci.base;
in
{
  options = {
    hci.base = {
    };
  };

  config = {
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 10;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;
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
