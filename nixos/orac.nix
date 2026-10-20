{ inputs, pkgs, lib, ... }:
{
  imports = [
    ../modules/nixos/common/ssh-keys.nix
    ../modules/nixos/orac/services.nix
    ../modules/nixos/common/tailscale.nix
    ../modules/nixos/orac/headscale.nix
    # ../modules/nixos/common/nebula.nix
    ../modules/nixos/orac/wireguard.nix
    ../modules/soju.nix
    ../modules/containers/docker/pangolin.nix
    ../modules/forgejo.nix
    # ../modules/adguard.nix
    ../modules/containers/docker/juicefs.nix
    # ../modules/containers/docker/ghost.nix  # TODO: uncomment after `docker compose down` on ghost-docker
    ../modules/containers/docker/minuspod.nix
    ../modules/nixos/orac/restic.nix
    ../modules/containers/docker/karakeep/docker-compose.nix
    ../modules/nixos/orac/monitoring.nix
    ../modules/containers/docker/crowdsec/crowdsec.nix
    ../pkgs/deathsite/deathsite-module.nix
    ../modules/umami.nix
    # ../modules/containers/docker/hermes/server.nix
    ../modules/containers/docker/hermes/hindsight.nix
    ../modules/nixos/orac/mullvad-exit.nix
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
      9119
    ];
    allowedUDPPorts = [
      80
      443
      8222
      3001
      3004
      3010
      2586
      9119
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
  boot.kernel.sysctl."net.ipv4.ip_nonlocal_bind" = 1;
  zramSwap.enable = true;
  networking.hostName = "orac";
  networking.domain = "";

  /*
  services.nebula.networks.deathmesh = {
    isLighthouse = true;
    settings.relay.am_relay = true;
    ca = "/etc/nixos/secrets/ca.crt";
    cert = "/etc/nixos/secrets/orac.crt";
    key = "/etc/nixos/secrets/orac.key";
  };
  */

services.hermes-agent = {
    enable = true;
    user = "death916";
    group = "users";
    createUser = false;
    stateDir = "/home/death916";
    environmentFiles = [ "/home/death916/.hermes/hermes.env" ];
    environment = {
      AGENT_BROWSER_EXECUTABLE_PATH = "/run/current-system/sw/bin/chromium";
    };
    addToSystemPackages = true;
    extraPackages = [ pkgs.agent-browser ];
    package = pkgs.callPackage ../pkgs/hermes-agent-patched.nix {
      inherit inputs;
      system = "aarch64-linux";
      patchFile = ../patches/hermes/kanban-db-board-precedence.patch;
    };
};

  fileSystems."/var/build" = {
    device = "/dev/disk/by-uuid/343a9352-6045-4d6a-8244-54ffd6940945";
    fsType = "ext4";
    options = [ "noatime" "nofail" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/build 0775 death916 users -"
    "d /var/build/jfsCache 0775 death916 users -"
  ];

  systemd.services.var-build-perms = {
    after = [ "var-build.mount" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/install -d -o death916 -g users -m 0775 /var/build /var/build/jfsCache";
    };
  };

  # Hermes 0.21+ spawns every cron run as a "restart-safe" worker via
  # `systemd-run --user --scope` so the job survives a gateway restart. That
  # needs a reachable *user* D-Bus session, which a system service never
  # inherits from a login session. Without these two vars every cron tick
  # fails at dispatch (restart-safe scope unavailable) and no job ever runs.
  systemd.services.hermes-agent.serviceConfig.ReadWritePaths = lib.mkAfter [ "/var/build" ];

  systemd.services.hermes-agent.environment = {
    AGENT_BROWSER_EXECUTABLE_PATH = "/run/current-system/sw/bin/chromium";
    HERMES_MANAGED = lib.mkForce "false";
    XDG_RUNTIME_DIR = "/run/user/1000";                      # death916's uid
    DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
  };

  system.activationScripts."hermes-agent-unmanaged" = {
    deps = [ "hermes-agent-setup" ];
    text = ''
      ${pkgs.coreutils}/bin/install -o death916 -g users -m 0644 ${pkgs.writeText "hermes-managed" "false"} /home/death916/.hermes/.managed
    '';
  };

  systemd.services.hermes-dashboard = {
    wantedBy = [ "multi-user.target" ];
    after = [ "hermes-agent.service" ];
    serviceConfig = {
      User = "death916";
      Group = "users";
      Restart = "always";
      RestartSec = 5;
      Environment = "HERMES_HOME=/home/death916/.hermes";
      ExecStart = "/run/current-system/sw/bin/hermes dashboard --host 0.0.0.0 --port 9119 --no-open";
    };
  };

  services.deathsite.enable = true;

  environment.variables = {
    TERM = "xterm-256color";
  };

  environment.systemPackages = with pkgs; [
    chromium
    agent-browser
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.settings.auto-optimise-store = true;

  boot.kernelPackages = (import inputs.nixpkgs-kernel-6-18-38 {
    inherit (pkgs) system;
    config.allowUnfree = true;
  }).linuxPackages;

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
