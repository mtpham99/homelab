{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hci.ceph;

  uuidRegex = "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}";

  stripSubnetPrefix = cidr: builtins.head (builtins.split "/" cidr);

  networkOption =
    description:
    lib.mkOption {
      type = lib.types.strMatching "^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$";
      inherit description;
      example = "192.168.0.1/24";
    };

  hostname = config.networking.hostName;
in
{
  options = {
    hci.ceph = {
      clusterId = lib.mkOption {
        type = lib.types.strMatching uuidRegex;
        description = "unique cluster identifier (fsid)";
      };

      clusterNetwork = networkOption "cluster network";
      publicNetwork = networkOption "public network";

      monNodes = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "list of nodes from 'hci.base.cluster' attrset to use as ceph monitors";
        example = [
          "node01"
          "node02"
          "node03"
        ];
      };

      mdsNodes = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "list of nodes from 'hci.base.cluster' attrset to use as ceph metadata servers";
        example = [
          "node01"
          "node02"
        ];
      };

      osds = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "list of osd ids on this node";
        example = [
          "0"
          "1"
        ];
      };
    };
  };

  config =
    let
      isCephMon = builtins.elem hostname cfg.monNodes;
      isCephMds = builtins.elem hostname cfg.mdsNodes;
      isCephOsd = cfg.osds != [ ];

      cephPublicIp = node: stripSubnetPrefix config.hci.base.cluster.${node}.ipv4.cephPublic;
      cephClusterIp = node: stripSubnetPrefix config.hci.base.cluster.${node}.ipv4.cephCluster;
    in
    {
      environment.systemPackages = [ pkgs.ceph ];

      # install custom ceph-bootstrap utils
      systemd.tmpfiles.rules = [
        "d /root/ceph-bootstrap 0750 root root -"

        "L+ /root/ceph-bootstrap/01-ceph-mon.sh - - - - ${./ceph-bootstrap/01-ceph-mon.sh}"
      ];

      # ceph admin keyring
      sops.secrets."ceph/client_admin_key" = { };
      sops.templates."ceph.client.admin.keyring" = {
        path = "/etc/ceph/ceph.client.admin.keyring";
        content = ''
          [client.admin]
            key = ${config.sops.placeholder."ceph/client_admin_key"}
            caps mds = "allow *"
            caps mgr = "allow *"
            caps mon = "allow *"
            caps osd = "allow *"
        '';
      };

      # ceph monitor keyring
      # staged with ceph-bootstrap utils and installed via monitor bootstrap
      sops.secrets."ceph/mon_key" = lib.mkIf isCephMon { };
      sops.templates."ceph.mon.keyring" = lib.mkIf isCephMon {
        path = "/root/ceph-bootstrap/ceph.mon.keyring";
        content = ''
          [mon.]
            key = ${config.sops.placeholder."ceph/mon_key"}
            caps mon = "allow *"
        ''
        + config.sops.templates."ceph.client.admin.keyring".content;
      };

      # firewall
      # see: https://docs.ceph.com/en/latest/rados/configuration/network-config-ref/#ip-tables
      networking.firewall.interfaces = {
        # ceph-mon (public network)
        vlan41.allowedTCPPorts = [
          3300 # messenger v2
          6789 # messenger v1
        ];

        # ceph-daemons: ceph-osd, ceph-mds, ceph-mgr (public network)
        # binds to first available in range: [6800, 7568]
        vlan41.allowedTCPPortRanges = [
          {
            from = 6800;
            to = 7568;
          }
        ];

        # ceph-osd replication
        # binds to first available in range: [6800, 7568]
        vlan40.allowedTCPPortRanges = [
          {
            from = 6800;
            to = 7568;
          }
        ];
      };

      services.ceph = {
        enable = true;

        global = {
          fsid = cfg.clusterId;

          monInitialMembers = builtins.concatStringsSep ", " cfg.monNodes;
          monHost = lib.concatMapStringsSep ", " cephPublicIp cfg.monNodes;

          clusterNetwork = cfg.clusterNetwork;
          publicNetwork = cfg.publicNetwork;
        };

        mon = {
          enable = isCephMon;
          daemons = [ hostname ];
        };
        mgr = {
          enable = isCephMon;
          daemons = [ hostname ];
        };
        mds = {
          enable = isCephMds;
          daemons = [ hostname ];
        };
        osd = {
          enable = isCephOsd;
          daemons = cfg.osds;
          extraConfig = { };
        };
      };

      systemd.services =
        let
          # make "ceph-osd-${osdId}" services depend on "ceph-volume-activate"
          cephOsdReqVolActivate = lib.genAttrs (builtins.map (osdId: "ceph-osd-${osdId}") cfg.osds) (_: {
            requires = [ "ceph-volume-activate.service" ];
            after = [ "ceph-volume-activate.service" ];
          });
        in
        {
          ceph-volume-activate = lib.mkIf isCephOsd {
            description = "activate ceph osds";
            after = [ "local-fs.target" ];
            path = [
              # packages missing from ceph wrapper
              # see: https://github.com/NixOS/nixpkgs/issues/147801#issue-1065600852
              pkgs.lvm2 # lvm
              pkgs.util-linux # nsenter
            ];
            restartIfChanged = false;
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStart = "${pkgs.ceph}/bin/ceph-volume lvm activate --all --no-systemd";
            };
          };
        }
        // cephOsdReqVolActivate;
    };
}
