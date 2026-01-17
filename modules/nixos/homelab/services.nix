# ~/nixconfig/modules.new/nixos/homelab/services.nix
{
  config,
  pkgs,
  unstablePkgsHA,
  ...
}:
{
  imports = [
    ../../adguard.nix
    ./restic.nix
    ./monitoring.nix
    ../../c2cscrape.nix
    # ../../containers/docker/immich.nix # Import the new Immich Docker container config
    ../../../modules/containers/docker/dispatcharr/docker-compose.nix
  ];
  arrSuite.enable = true;
  services.samba.shares.Media.path = "/media/storage/media";

  services.c2cscrape = {
    enable = true;
    dataDir = "/media/storage/media/books/audio/podcasts/C2C";
    user = "death916";
  };
  #  virtualisation.incus.enable = true;
  services.qbittorrent = {
    enable = true;
    profileDir = "/storage/services/qbittorrent";
    user = "qbittorrent";
    group = "media_services";
    webuiPort = 8090;
    openFirewall = true;
    package = pkgs.qbittorrent-nox;
  };
  users.users.audiobookshelf = {
    isSystemUser = true;
    group = "media_services";
  };

  users.users.c2c = {
    isSystemUser = true;
    group = "media_services";
    extraGroups = [ "media_services" ];
  };

  services.audiobookshelf = {
    enable = true;
    user = "audiobookshelf";
    group = "media_services";
    host = "0.0.0.0";
    port = 13378;
  };

  systemd.tmpfiles.rules = [

    "d /storage/services/qbittorrent 0755 qbittorrent media_services - -"

    "d /storage/services/qbittorrent/config 0755 qbittorrent media_services - -"

    "d /media/storage/media/books/audio/podcasts/C2C 0777 c2c media_services - -"
    "d /storage/services/immich 0770 immich media_services -"
    "d /storage/services/immich/upload 0770 immich media_services -"
    "d /storage/services/immich/upload/library 0770 immich media_services -"
    "d /storage/services/immich/upload/thumbs 0770 immich media_services -"
    "d /storage/services/immich/upload/encoded-video 0770 immich media_services -"
    "d /storage/services/immich/upload/profile 0770 immich media_services -"
    "d /storage/services/immich/upload/upload 0770 immich media_services -"
    "d /storage/services/immich/upload/backup 0770 immich media_services -"

    "f /storage/services/immich/upload/library/.immich 0660 immich media_services -"
    "f /storage/services/immich/upload/thumbs/.immich 0660 immich media_services -"
    "f /storage/services/immich/upload/encoded-video/.immich 0660 immich media_services -"
    "f /storage/services/immich/upload/upload/.immich 0660 immich media_services -"
    "f /storage/services/immich/upload/profile/.immich 0660 immich media_services -"
    "f /storage/services/immich/upload/backups/.immich 0660 immich media_services -"
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
        user = "1000:1000";
        image = "sigoden/dufs:latest";
        ports = [ "5000:5000" ];
        volumes = [ "/media/storage/media/:/data" ];
        cmd = [
          "/data"
          "-A"
        ];
      };
      # c2c-scraper = {
      # image = "death916/c2cscrape:latest";
      # volumes = [
      # "/media/storage/media/books/audio/podcasts/C2C:/downloads"
      # "/media/storage/media/docker/volumes/c2cscrape:/app/data"
      # ];
      # user = "${toString config.users.users.c2c.uid}:${toString config.users.groups.media_services.gid}";
      # environment = {
      # TZ = "America/Los_Angeles";
      # };
      # autoStart = true;
      # extraOptions = [ "--dns=8.8.8.8" ];
      # };
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
      # ovmf.enable = true;
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

  users.users.immich = {
    isSystemUser = true;
    extraGroups = [ "media_services" ];
  };

  systemd.services.immich-server.unitConfig.RequiresMountsFor = [ "/storage" ];
  systemd.services.immich-microservices.unitConfig.RequiresMountsFor = [ "/storage" ];
  systemd.services.immich-machine-learning.unitConfig.RequiresMountsFor = [ "/storage" ];
  systemd.services.immich-server.serviceConfig.ReadWritePaths = [ "/storage/services/immich" ];
  systemd.services.immich-microservices.serviceConfig.ReadWritePaths = [ "/storage/services/immich" ];
  systemd.services.immich-machine-learning.serviceConfig.ReadWritePaths = [
    "/storage/services/immich"
  ];

  services.immich = {
    enable = true;
    host = "0.0.0.0";
    port = 2283;
    mediaLocation = "/storage/services/immich/upload";
    environment.IMMICH_IGNORE_MOUNT_CHECK_ERRORS = "true";

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
    manix
    qemu
    virt-manager
    usbutils
    yazi
  ];
}
