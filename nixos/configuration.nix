# ~/nixconfig/nixos/configuration.nix.new
{
  config,
  pkgs,
  overlays,
  ...
}:

{
  # Apply the overlays passed from the flake
  nixpkgs.overlays = [
    overlays.rust
    overlays.halloy
  ];

  imports = [
    ./hardware-configuration.nix
    ../modules/nixos/laptop/desktop.nix
    ../modules/nixos/common/base.nix
    ../modules/nixos/laptop/user.nix
    ../modules/nixos/common/tailscale.nix
    ../modules/nixos/laptop/hyprland-deps.nix # New module for Hyprland dependencies
  ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd Hyprland";
        user = "death916";
      };
    };
  };

  system.stateVersion = "24.11";
}
