# ~/nixconfig/nixos/homelab.nix.new
{
  imports = [
    ../modules/nixos/common/base.nix
    ../modules/nixos/common/tailscale.nix
  ];

}
