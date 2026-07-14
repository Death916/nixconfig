{ inputs, pkgs, ... }:
{
  imports = [
    ../modules/nixos/common/fish.nix
    ../modules/nixos/common/ssh-keys.nix
    ../modules/nixos/orac/services.nix
    ../modules/nixos/common/tailscale.nix
    ../modules/nixos/common/nebula.nix
    ../modules/nixos/orac/wireguard.nix
    ../modules/soju.nix
    ../modules/containers/docker/pangolin.nix
    ../modules/forgejo.nix
    # ../modules/adguard.nix
    ../modules/containers/docker/juicefs.nix
    # ../modules/containers/docker/ghost.nix  # TODO: uncomment after `docker compose down` on ghost-docker
    ../modules/nixos/orac/restic.nix
    ../modules/containers/docker/karakeep/docker-compose.nix
    ../modules/nixos/orac/monitoring.nix
    ../modules/containers/docker/crowdsec/crowdsec.nix
    ../pkgs/deathsite/deathsite-module.nix
    ../modules/umami.nix
    # ../modules/containers/docker/hermes/server.nix
    ../modules/containers/docker/hermes/hindsight.nix
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
      8222
      3001
      3004
      3010
      2586
    ];
    allowedUDPPorts = [
      80
      443
      8222
      3001
      3004
      3010
      2586
    ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "yes";
      AllowUsers = [ "death916" ];
      AllowTcpForwarding = true;
      AllowStreamLocalForwarding = "yes";
      StreamLocalBindUnlink = "yes";
    };
  };
  time.timeZone = "America/Los_Angeles";
  users.users.death916 = {
    isNormalUser = true;
    home = "/home/death916";
    description = "death916";
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
    linger = true;
  };
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "orac";
  networking.domain = "";

  services.nebula.networks.deathmesh = {
    isLighthouse = true;
    settings.relay.am_relay = true;
    ca = "/etc/nixos/secrets/ca.crt";
    cert = "/etc/nixos/secrets/orac.crt";
    key = "/etc/nixos/secrets/orac.key";
  };

  services.hermes-agent = {
    enable = true;
    user = "death916";
    group = "users";
    createUser = false;
    stateDir = "/home/death916";
    environmentFiles = [ "/home/death916/.hermes/hermes.env" ];
    addToSystemPackages = true;
    environment = {
      HERMES_DASHBOARD = "1";
      HERMES_DASHBOARD_INSECURE = "1";
      HERMES_DASHBOARD_HOST = "0.0.0.0";
    };
  };

  services.deathsite.enable = true;

  environment.variables = {
    TERM = "xterm-256color";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.settings.auto-optimise-store = true;

  boot.loader.grub.configurationLimit = 2;
  boot.initrd.compressor = "zstd";
  boot.loader.grub.font = null;
  # Disable translations to save space on small /boot
  boot.loader.grub.extraConfig = ''
    set locale_dir=$prefix/locale
    set lang=en_US
  '';

  services.journald.extraConfig = ''
    SystemMaxUse=500M
  '';

  system.stateVersion = "25.05";
}
