{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hci.network;

  ipv4NoPrefixOption =
    description:
    lib.mkOption {
      type = lib.types.strMatching "^([0-9]{1,3}\\.){3}[0-9]{1,3}$";
      inherit description;
      example = "192.168.0.1";
    };

  ifaceByPciOption =
    description:
    lib.mkOption {
      type = lib.types.strMatching "^pci-[0-9a-f]{4}:[0-9a-f]{2}:[0-9a-f]{2}\\.[0-9]$";
      inherit description;
      example = "pci-0000:02:00.0";
    };
in
{
  options = {
    hci.network = {
      interfaces = {
        dataTrunk = ifaceByPciOption "pci path of iface used for data trunk";
        storageTrunk = ifaceByPciOption "pci path of iface used for storage trunk";
        oobMgmt = ifaceByPciOption "pci path of iface used for out-of-band management";
      };

      gateway = ipv4NoPrefixOption "gateway ipv4 address";
      dns = ipv4NoPrefixOption "dns ipv4 address";
    };
  };

  config = {
    networking.useDHCP = false;
    hardware.facter.detected.dhcp.enable = false;

    networking.useNetworkd = true;
    systemd.network = (
      let
        staticNetwork = {
          DHCP = "no";
          IPv6AcceptRA = false;
          LinkLocalAddressing = "no";
        };
      in
      {
        enable = true;
        wait-online.timeout = 30;
        config.networkConfig.IPv6PrivacyExtensions = false;

        netdevs = {
          "20-vlan50" = {
            netdevConfig.Name = "vlan50";
            netdevConfig.Kind = "vlan";
            vlanConfig.Id = 50;
          };
          "20-vlan40" = {
            netdevConfig.Name = "vlan40";
            netdevConfig.Kind = "vlan";
            vlanConfig.Id = 40;
          };
          "20-vlan41" = {
            netdevConfig.Name = "vlan41";
            netdevConfig.Kind = "vlan";
            vlanConfig.Id = 41;
          };
        };

        networks = {
          "10-oob-mgmt" = {
            matchConfig.Path = cfg.interfaces.oobMgmt;

            networkConfig = staticNetwork;
            linkConfig.MTUBytes = 1500;
            linkConfig.RequiredForOnline = false;
          };

          "30-data-trunk" = {
            matchConfig.Path = cfg.interfaces.dataTrunk;

            vlan = [ "vlan50" ];

            networkConfig = staticNetwork;
            linkConfig.MTUBytes = 9000;
            linkConfig.RequiredForOnline = "carrier";
          };
          "50-vlan50" = {
            matchConfig.Name = "vlan50";

            address = [ config.hci.base.cluster."${config.networking.hostName}".ipv4.host ];
            gateway = [ cfg.gateway ];
            dns = [ cfg.dns ];

            networkConfig = staticNetwork;
            linkConfig.MTUBytes = 1500;
            linkConfig.RequiredForOnline = "routable";
          };

          "30-storage-trunk" = {
            matchConfig.Path = cfg.interfaces.storageTrunk;

            vlan = [
              "vlan40"
              "vlan41"
            ];

            networkConfig = staticNetwork;
            linkConfig.MTUBytes = 9000;
            linkConfig.RequiredForOnline = "carrier";
          };
          "50-vlan40" = {
            matchConfig.Name = "vlan40";

            address = [ config.hci.base.cluster."${config.networking.hostName}".ipv4.cephCluster ];

            networkConfig = staticNetwork;
            linkConfig.MTUBytes = 9000;
            linkConfig.RequiredForOnline = "routable";
          };
          "50-vlan41" = {
            matchConfig.Name = "vlan41";

            address = [ config.hci.base.cluster."${config.networking.hostName}".ipv4.cephPublic ];

            networkConfig = staticNetwork;
            linkConfig.MTUBytes = 9000;
            linkConfig.RequiredForOnline = "routable";
          };

          "90-unmanaged" = {
            matchConfig.Name = [
              "virbr*"
              "vnet*"
              "veth*"
              "docker*"
              "tap*"
              "cni*"
            ];
            linkConfig.Unmanaged = true;
          };
        };
      }
    );
  };
}
