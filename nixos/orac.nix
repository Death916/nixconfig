{
  imports = [
    ../modules/nixos/orac/services.nix
    ../modules/nixos/common/tailscale.nix
    ../modules/soju.nix
    ../modules/containers/docker/pangolin.nix
    # ../modules/forgejo.nix
    ../modules/adguard.nix
    ../modules/containers/docker/juicefs.nix
    ../modules/nixos/orac/restic.nix
    ../modules/containers/docker/karakeep/docker-compose.nix
    ../modules/nixos/orac/monitoring.nix
    ../modules/containers/docker/crowdsec/crowdsec.nix
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
      8222
    ];
    allowedUDPPorts = [
      80
      443
      8222
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

  users.users.death916.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA02MxjL3+2gY3TenuezzmqObP7/AZ3rh/0PH7lqfxQY death916@nixos"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDoxgXUwp/ceXyfsOOSTBIpOIXZ4CyNcXj/W0wkkVhqjoiZOXlls1mjGvmFYmYbKw8He055+cxjRyhQqBCblwwy7Kj/o9ZE7Tg/tYoU//Iog/wReSoSlms58UR/qZk2Rk0mD0RfmW22iAJp8e+Z9qxF1h+1MZy6WPb3R7+KiN5U9q6ls71bF2AP+W5PV/voMi5R/66JolPpcVrYhrNKMPNSqefAD0Q0xeuoDff0LIsRuHZVGDE0MxCPWHpikQ/5K3bPjw1yRxo55buwDLddRmKZ5OSwtfnoI02BLh7zJvrctMPpKDQa2L+He5woC92/m7pmPFhdBynJ5e30KvQGsiUuB4oPye/29quZmybOR3JXbBZjrJ2kmAhrdt1PxoywWKOOTX5Xdw6d5kSYq00TAhDpcLcvGy3lh0tpLk8ia8HVfN7pmJQTDi+CW72zlHyPQILPsxR88ex5MGqE2GupP5wFYR+J6ncumh7Chdes2vD7r9uA2GUy8hmAfDhUG4B1yHs= death916@nixos"
  ];
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA02MxjL3+2gY3TenuezzmqObP7/AZ3rh/0PH7lqfxQY death916@nixos"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDoxgXUwp/ceXyfsOOSTBIpOIXZ4CyNcXj/W0wkkVhqjoiZOXlls1mjGvmFYmYbKw8He055+cxjRyhQqBCblwwy7Kj/o9ZE7Tg/tYoU//Iog/wReSoSlms58UR/qZk2Rk0mD0RfmW22iAJp8e+Z9qxF1h+1MZy6WPb3R7+KiN5U9q6ls71bF2AP+W5PV/voMi5R/66JolPpcVrYhrNKMPNSqefAD0Q0xeuoDff0LIsRuHZVGDE0MxCPWHpikQ/5K3bPjw1yRxo55buwDLddRmKZ5OSwtfnoI02BLh7zJvrctMPpKDQa2L+He5woC92/m7pmPFhdBynJ5e30KvQGsiUuB4oPye/29quZmybOR3JXbBZjrJ2kmAhrdt1PxoywWKOOTX5Xdw6d5kSYq00TAhDpcLcvGy3lh0tpLk8ia8HVfN7pmJQTDi+CW72zlHyPQILPsxR88ex5MGqE2GupP5wFYR+J6ncumh7Chdes2vD7r9uA2GUy8hmAfDhUG4B1yHs= death916@nixos"
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  boot.loader.grub.configurationLimit = 2;

  system.stateVersion = "25.05";
}
