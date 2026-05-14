{
  imports = [
    ../modules/nixos/common/base.nix
    ../modules/nixos/common/tailscale.nix
    ../nixos/oracle-proxy-hardware.nix
    ../modules/nixos/oracle-proxy/services.nix
    ../modules/soju.nix
  ];

  users.users.death916 = {
    isNormalUser = true;
    home = "/home/death916";
    description = "death916";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

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

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  networking.hostName = "oracle-proxy";
  networking.domain = "";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

}
