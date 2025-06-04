{ lib, ... }:

with lib;

let
  storagePoolSource = "/var/lib/incus/storage-pools/default";
  defaultDiskSize = "50GiB";
  hostBridgeName = "br0"; # This must match the bridge name created in homelab.nix
in
{
  config = { 
    virtualisation.incus.preseed = {
      profiles = [
        {
          name = "default";
          config = {
            "boot.autostart" = "true"; # VMs using this profile will auto-start
          };
          devices = {
            eth0 = {
              name = "eth0";
              nictype = "bridged";        # Use 'bridged' nictype
              parent = hostBridgeName;    # Connect to the host-managed bridge 'br0'
              type = "nic";
            };
            root = {
              path = "/";
              pool = "default";         # Use the default storage pool
              size = defaultDiskSize;
              type = "disk";
            };
          };
        }
      ];

      storage_pools = [
        {
          name = "default";
          driver = "dir";   # Use directory-backed storage
          config = {
            source = storagePoolSource;
          };
        }
      ];
    };
    # If using NixOS firewall & VMs have DHCP issues (unlikely with host bridge but possible):
    # consider adding to homelab.nix: networking.firewall.trustedInterfaces = [ "br0" ];
  };
}

