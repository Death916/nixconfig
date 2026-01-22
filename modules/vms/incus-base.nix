{ lib, ... }:

with lib;

let
  hostBridgeName = "br0";
in
{
  config = {
    virtualisation.incus.preseed = {
      # Define two storage pools: one on the SSD and one on /storage.
      storage_pools = [
        {
          name = "ssd-pool";
          driver = "dir";
          config = {
            # This path is on your root SSD.
            source = "/home/death916/incus/incus-data";
          };
        }
        {
          name = "bulk-pool";
          driver = "dir";
          config = {
            source = "/storage/incus-data";
          };
        }
      ];

      profiles = [
        {
          name = "default";
          config = {
            "boot.autostart" = "true";
          };
          devices = {
            eth0 = {
              name = "eth0";
              nictype = "bridged";
              parent = hostBridgeName;
              type = "nic";
            };
            root = {
              path = "/";
              # Point the root disk to the ssd-pool.
              pool = "ssd-pool";
              size = "50GiB";
              type = "disk";
            };
          };
        }
      ];
    };
  };
}
