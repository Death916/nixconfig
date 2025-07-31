{
  imports = [
    ../modules/nixos/common/base.nix
    ../modules/nixos/common/tailscale.nix
    ../nixos/oracle-proxy-hardware.nix
  ];

  users.users.death916 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.bash;
  };
}
