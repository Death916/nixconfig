# ~/nixconfig/nixos/configuration.nix.new
{
  imports = [
    ./hardware-configuration.nix
    ../modules/nixos/laptop/desktop.nix
    ../modules/nixos/common/base.nix
    ../modules/nixos/laptop/user.nix
    ../modules/nixos/common/tailscale.nix
  ];
}
