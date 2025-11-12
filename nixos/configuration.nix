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
    # overlays.rust
    # overlays.halloy
  ];

  imports = [
    ./hardware-configuration.nix
    ../modules/nixos/laptop/desktop.nix
    ../modules/nixos/common/base.nix
    ../modules/nixos/laptop/user.nix
    ../modules/nixos/common/tailscale.nix
    ../modules/nixos/laptop/hyprland-deps.nix # New module for Hyprland dependencies
    ../modules/nixos/laptop/restic.nix
  ];

  # nix.settings.substituters = [
  # "https://hyprland.cachix.org"
  # "https://cache.flox.dev"
  # "https://nix-community.cachix.org"
  # ];
  # nix.settings.trusted-public-keys = [
  # "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
  # "flox-store-public-0:8c/B+kjIaQ+BloCmNkRUKwaVPFWkriSAd0JJvuDu4F0="
  # "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  # ];




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
