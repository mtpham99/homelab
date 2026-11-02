{
  config,
  lib,
  pkgs,
  ...
}:
{
  hci.network.gateway = "10.137.50.1";
  hci.network.dns = "10.137.50.1";

  hci.base.cluster = {
    "hci01" = {
      ipv4.host = "10.137.50.11/24";
      ipv4.cephCluster = "10.137.40.11/24";
      ipv4.cephPublic = "10.137.41.11/24";
      ipv4.oobMgmt = "10.137.10.11/24";
    };
    "hci02" = {
      ipv4.host = "10.137.50.12/24";
      ipv4.cephCluster = "10.137.40.12/24";
      ipv4.cephPublic = "10.137.41.12/24";
      ipv4.oobMgmt = "10.137.10.12/24";
    };
    "hci03" = {
      ipv4.host = "10.137.50.13/24";
      ipv4.cephCluster = "10.137.40.13/24";
      ipv4.cephPublic = "10.137.41.13/24";
      ipv4.oobMgmt = "10.137.10.13/24";
    };
  };

  hci.ceph = {
    clusterNetwork = "10.137.40.0/24";
    publicNetwork = "10.137.41.0/24";

    clusterId = "0fc4ea88-b2c4-47dc-bb66-5dfb9d74ae63";

    monNodes = [
      "hci01"
      "hci02"
      "hci03"
    ];
    mdsNodes = [
      "hci01"
      "hci02"
      "hci03"
    ];
  };
}
