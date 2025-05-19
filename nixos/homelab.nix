# ./nixos/homelab.nix
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
   ../modules/nextcloud-setup.nix
   ../modules/media/qbittorrent.nix
   ../modules/media/arr-suite.nix
   ../modules/home-assistant.nix 
   # Import any shared modules from your ./modules directory if applicable
    # e.g., (../modules/common-settings.nix)
  ];
  arrSuite.enable = true;
#  nixpkgs.config.allowUnfree = true;
  boot.loader.systemd-boot.enable = true; # Or grub, as appropriate for your server
  boot.loader.efi.canTouchEfiVariables = true;
  powerManagement.cpuFreqGovernor = "ondemand"; # hopefully fix low cpu freq
  hardware.cpu.amd.updateMicrocode = true; # same 
  networking.hostName = "homelab"; # Set the server's hostname
  boot.initrd.kernelModules = [ "dm_mod" "dm_thin_pool" ]; # Device mapper core
  boot.initrd.availableKernelModules = [
    # For LVM thin provisioning
    # Add filesystem types you expect to find on these LVs, e.g., "ext4", "xfs", "zfs" (if using ZFS on LVM)
    "ext4"
    "xfs" 
  ];
  services.lvm.enable = true;
  services.lvm.boot.thin.enable = true; # Crucial for thin pools
  nix.settings.experimental-features = ["nix-command" "flakes"];  
  # Mount for your media LV (from /dev/sdd via media VG)
  fileSystems."/media" = { 
    device = "/dev/media/vm-101-disk-0"; 
    fsType = "ext4";
    options = [ "defaults" "nofail" ]; 
  };

  # Mount for your newly formatted storage LV
  fileSystems."/storage" = {
    device = "/dev/Storage/data_lv"; # Path to your new thick LV
    fsType = "ext4";                 # Or xfs if you chose that
    options = [ "defaults" "nofail" ];
  }; 
 
  # Basic firewall
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ]; # Allow SSH
  networking.firewall.trustedInterfaces = [ "tailscale0" ]; # <--- ADDED for Tailscale access
  # SSH Server configuration
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    openFirewall = true;
    settings.PasswordAuthentication = false; # Recommended: use SSH keys
    settings.PermitRootLogin = "no";       # Recommended
  };
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };
  networking.firewall.checkReversePath = "loose"; #needed for tailscale nodes
  # Define the 'death916' user for the server
  users.users.death916 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "media_services" "nextcloud"]; # For sudo access
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCte9KjJUSn4xBPEKCk9QER6+jF+C0uBatVl27zIamYsryyHdFrmqK2DAg7OhqTHqzjxID6sp6d57MsJqOUAtwXbUDMLffqBSerUxfTm+1SPDrhL0GSvo0QVjMLVseOEq8d2qXgW1R7dIk412VbO5e9SAump5aJOHI/SzT6VLoUczalmqrjnDacWQMeLu/TSOZHcfrhjYSg+b1xbc1vHp6C4obOb8JIj/anAieT/1P36MhlNW79ow6PWenLemBYeeezFrKtESF1oMc8jmcxogzgLamlqhKYAHlKhOuBF6u0nRneI5IPDbbMF5zwEv5szCEKj8XZJVYUk8uUg7ARyppjcA7yAXuaNKBNxa7tfjqWrDWOACn97ufE5FFJt0XH5JzkXcDh96K8ZSZaWxMRu2s+GlIu/1F415xtVfe1d79HYkWke/ewaQ4NqgOt8f7wRvyzabpQZDzkaXO0UoK65O2HyUur33XWCEmV+1pB6BrS8pD+1I4Tvbnc+rOgtHTTRfKqezKqZmaErEOxClBwvWjvn0PzhGSoClTGXPjhl239/sH0JGY09dTBh8GtAVbfv+jFO6nm6aR7O/OwSaohY3uOdRo8XyxJr4XyGAaBNRdm6BUJRnB4W51J49IQBZzIe2NUkNMHeUT4jkxFpfhkujnSFw2ZnOLkERpwkltAlbwuLw== tavn1992@gmail.com" # <<-- REPLACE THIS WITH YOUR SSH PUBLIC KEY for death916
      # Add more keys if needed
    ];
    # If 'death916' needs a password on the server (less secure than key-only)
    # initialPassword = "yoursecurepassword"; # Or use hashed password
  };

  users.users.audiobookshelf = {
    isSystemUser = true; # System user, doesn't need a home directory by default for services
    group = "media_services"; # Primary group
    # extraGroups = [ "media_services" ]; # Alternatively, if you want a different primary group
  };
  
  users.users.nextcloud = {
    # This merges with the 'nextcloud' user definition from services.nextcloud in the imported module
    extraGroups = [ "media_services" ];
  };
  users.groups.media_services = {};
  users.groups.nextcloud = {};
  # homelab services

  services.plex = {
  enable = true;
  openFirewall = true;
  user="death916";
  };

  services.audiobookshelf = {
    enable = true;
    user = "audiobookshelf";
    group = "media_services";
    host = "0.0.0.0";  # <--- ADD THIS LINE to listen on all IPv4 interfaces
    port = 13378;   
  };
  
  #networking.firewall.allowedTCPPorts = [19999];
#  services.netdata.package = pkgs.netdata.override { withCloud = true; };
  services.netdata = {
    
    package = pkgs.netdata.override {
      withCloud = true;
    };  
    enable = true;
    config = {
      global = {
        "memory mode" = "ram";
        "debug log" = "none";
        "access log" = "none";
        "error log" = "syslog";
      };
    };
  };
  
  users.users.qbittorrent.extraGroups = [ "media_services" ];
  users.groups.qbittorrent = {};

  services.qbittorrent = {
    enable = true;
    dataDir = "/storage/services/qbittorrent";
    user = "qbittorrent";
    group = "qbittorrent";
    port = 8090;
    openFirewall = true;
    package = pkgs.qbittorrent-nox;
  };

  systemd.tmpfiles.rules = [
    "d /storage/downloads 0775 root media_services - -"
    "d /storage/services/qbittorrent 0755 qbittorrent qbittorrent - -"
  ];

  
  services.jellyfin.enable = true;
  
    
 


  # Sudo access for the wheel group (which death916 is part of)
  security.sudo.wheelNeedsPassword = true; # Or false if you prefer passwordless sudo for wheel

  # Essential server packages
  environment.systemPackages = with pkgs; [
    git
    vim
    htop
    tmux
    tailscale
    lvm2
    rsync
    multipath-tools # kpartx
    btop
    wget    
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
    pkgs.jellyfin
    unzip
  ];
  
  # If you use custom overlays specific to this server:
  # nixpkgs.overlays = [(import ../overlays/homelab-overlay.nix)];

  system.stateVersion = "24.11"; # Set to your NixOS version
}
