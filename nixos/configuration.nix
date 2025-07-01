# ~/nixconfig/nixos/configuration.nix.new
{ config, pkgs, overlays, ... }:

{
  # Apply the overlays passed from the flake
  nixpkgs.overlays = [ overlays.rust overlays.halloy ];

  imports = [
    ./hardware-configuration.nix
    ../modules/nixos/laptop/desktop.nix
    ../modules/nixos/common/base.nix
    ../modules/nixos/laptop/user.nix
    ../modules/nixos/common/tailscale.nix
  ];
}
