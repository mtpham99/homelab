{
  config,
  lib,
  pkgs,
  ...
}:

{
  sops = {
    age.keyFile = "/var/lib/sops/keys.txt";
    age.generateKey = false;

    age.sshKeyPaths = [ ];
    gnupg.sshKeyPaths = [ ];

    defaultSopsFile = ../../../secrets/hci.enc.yaml;
    defaultSopsFormat = "yaml";
    secrets = {
      "hci_admin_password_hash".neededForUsers = true;

      "ssh_host_ed25519_key" = {
        key = "${config.networking.hostName}_host_keys/ssh/sk";
        path = "/etc/ssh/ssh_host_ed25519_key";
        restartUnits = [ "sshd.service" ];
      };
      "ssh_host_ed25519_key.pub" = {
        key = "${config.networking.hostName}_host_keys/ssh/pk";
        path = "/etc/ssh/ssh_host_ed25519_key.pub";
        mode = "0444";
      };

      "root_authorized_keys" = {
        key = "hci_admin_authorized_keys";
        path = "/etc/ssh/authorized_keys.d/root";
      };
      "hci_admin_authorized_keys" = {
        key = "hci_admin_authorized_keys";
        path = "/etc/ssh/authorized_keys.d/${config.users.users."hci-admin".name}";
        owner = config.users.users."hci-admin".name;
      };

      "hci_admin_id_ed25519" = {
        key = "hci_admin_keys/ssh/sk";
        path = "${config.users.users."hci-admin".home}/.ssh/id_ed25519";
        owner = config.users.users."hci-admin".name;
      };
      "hci_admin_id_ed25519.pub" = {
        key = "hci_admin_keys/ssh/pk";
        path = "${config.users.users."hci-admin".home}/.ssh/id_ed25519.pub";
        owner = config.users.users."hci-admin".name;
        mode = "0444";
      };
    };
  };
}
