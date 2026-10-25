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
}
