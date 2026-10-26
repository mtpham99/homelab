{
  config,
  lib,
  pkgs,
  ...
}:
{
  hci.network.gateway = "172.16.0.1";
  hci.network.dns = "172.16.0.1";

  hci.base.cluster = {
    "hcitest01" = {
      ipv4.host = "172.16.1.11/24";
      ipv4.cephCluster = "172.16.2.11/24";
      ipv4.cephPublic = "172.16.3.11/24";
      ipv4.oobMgmt = "172.16.0.11/24";
    };
    "hcitest02" = {
      ipv4.host = "172.16.1.12/24";
      ipv4.cephCluster = "172.16.2.12/24";
      ipv4.cephPublic = "172.16.3.12/24";
      ipv4.oobMgmt = "172.16.0.12/24";
    };
    "hcitest03" = {
      ipv4.host = "172.16.1.13/24";
      ipv4.cephCluster = "172.16.2.13/24";
      ipv4.cephPublic = "172.16.3.13/24";
      ipv4.oobMgmt = "172.16.0.13/24";
    };
  };
}
