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
    "hcitest01" = {
      ipv4.host = "10.137.50.21/24";
      ipv4.cephCluster = "10.137.40.21/24";
      ipv4.cephPublic = "10.137.41.21/24";
      ipv4.oobMgmt = "172.16.0.21/24";
    };
    "hcitest02" = {
      ipv4.host = "10.137.50.22/24";
      ipv4.cephCluster = "10.137.40.22/24";
      ipv4.cephPublic = "10.137.41.22/24";
      ipv4.oobMgmt = "172.16.0.22/24";
    };
    "hcitest03" = {
      ipv4.host = "10.137.50.23/24";
      ipv4.cephCluster = "10.137.40.23/24";
      ipv4.cephPublic = "10.137.41.23/24";
      ipv4.oobMgmt = "172.16.0.23/24";
    };
  };
}
