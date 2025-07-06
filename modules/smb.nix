{ config, pkgs, ... }:

{
  services.samba = {
    enable = true;
    openFirewall = false; 
    settings = {
      Media = {
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no"; # Disables guest access, requires a user login

        # This is the key: any new file or directory created through the share
        # will be assigned to the 'media_services' group.
        "force group" = "media_services";

        # Set permissions for new files/dirs to allow group write access.
        "create mask" = "0660";      # File permissions: rw-rw----
        "directory mask" = "0770";   # Directory permissions: rwxrwx---
      };
    };
  };

  # Enable network discovery service for clients.
  services.samba-wsdd = {
    enable = true;
    openFirewall = false;
  };
}

