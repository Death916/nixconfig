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
    ../modules/nixos/orac/restic.nix
    ../modules/containers/docker/karakeep/docker-compose.nix
    ../modules/nixos/orac/monitoring.nix
    ../modules/containers/docker/crowdsec/crowdsec.nix
    ../pkgs/deathsite/deathsite-module.nix
    ../modules/umami.nix
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

  services.deathsite.enable = true;

  environment.variables = {
    TERM = "xterm-256color";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  boot.loader.grub.configurationLimit = 2;

  system.stateVersion = "25.05";
}
