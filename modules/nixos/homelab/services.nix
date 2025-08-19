# ~/nixconfig/modules.new/nixos/homelab/services.nix
{
  config,
  pkgs,
  ...
}:
{
  #  imports = [ ../../containers/kopia-docker.nix ];
  arrSuite.enable = true;
  services.samba.shares.Media.path = "/media/storage/media";

  #  virtualisation.incus.enable = true;

  users.users.audiobookshelf = {
    isSystemUser = true;
    group = "media_services";
  };

  users.users.c2c = {
    isSystemUser = true;
    group = "media_services";
  };

  users.groups.media_services = { };

  services.audiobookshelf = {
    enable = true;
    user = "audiobookshelf";
    group = "media_services";
    host = "0.0.0.0";
    port = 13378;
  };

  users.groups.qbittorrent = { };
  users.users.qbittorrent.group = "qbittorrent";
  # users.groups.qbittorrent = {};
  users.users.qbittorrent.extraGroups = [ "media_services" ];

  # services.qbittorrent = {
  #   enable = true;
  #   dataDir = "/storage/services/qbittorrent";
  #   user = "qbittorrent";
  #   group = "qbittorrent";
  #   port = 8090;
  #   openFirewall = true;
  #   package = pkgs.qbittorrent-nox;
  # };

  systemd.tmpfiles.rules = [
    "d /storage/services/qbittorrent 0755 qbittorrent qbittorrent - -"
    "d /storage/services/qbittorrent/config 0755 qbittorrent qbittorrent - -"
    "d /media/storage/media/books/audio/podcasts/C2C 0775 c2c media_services - -"
  ];

  services.jellyfin.enable = true;

  services.actual = {
    enable = true;
    settings = {
      port = 5006;
    };
  };

  virtualisation.docker.enable = true;

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      dufs = {
        image = "sigoden/dufs:latest";
        ports = [ "5000:5000" ];
        volumes = [ "/media/storage/media/:/data" ];
        cmd = [
          "/data"
          "-A"
        ];
      };
      c2c-scraper = {
        image = "death916/c2cscrape:latest";
        volumes = [
          "/media/storage/media/books/audio/podcasts/C2C:/downloads"
          "/media/storage/media/docker/volumes/c2cscrape:/app/data"
        ];
        user = "c2c:media_services";
        environment = {
          TZ = "America/Los_Angeles";
        };
        autoStart = true;
        extraOptions = [ "--dns=8.8.8.8" ];
      };
      adguardhome = {
        image = "adguard/adguardhome:latest";
        autoStart = true;
        volumes = [
          "/storage/services/adguard/work:/opt/adguardhome/work"
          "/storage/services/adguard/data:/opt/adguardhome/conf"
        ];
        extraOptions = [ "--network=host" ];
      };
    };
  };

  systemd.services.kopia-backup = {
    description = "Kopia backup service for NixOS server";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = "/usr/local/bin/nixos-kopia-backup.sh";
      path = with pkgs; [
        coreutils
        kopia
      ];
    };
  };

  systemd.timers.kopia-backup = {
    description = "Daily Kopia backup timer";
    wantedBy = [ "timers.target" ];
    partOf = [ "kopia-backup.service" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      Unit = "kopia-backup.service";
    };
  };

  users.users.adguardhome = {
    isSystemUser = true;
    group = "adguardhome";
    extraGroups = [ "adgaurdhome-access" ];
  };
  users.groups.adguardhome-access = { };
  users.groups.adguardhome = { };

  security.sudo.wheelNeedsPassword = true;

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_full;
      runAsRoot = true;
      ovmf.enable = true;
    };
  };

  services.homeassistant-vm = {
    enable = true;
    imagePath = "/var/lib/libvirt/images/haos.qcow2";
    memory = 6096;
    vcpus = 4;
    bridge = "br0";
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 10";
    flake = "/home/death916/nixconfig/";
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    htop
    tmux
    tailscale
    lvm2
    rsync
    multipath-tools
    btop
    wget
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
    pkgs.jellyfin
    unzip
    kopia
    manix
    qemu
    virt-manager
    usbutils
  ];
}
