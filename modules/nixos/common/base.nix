# ~/nixconfig/modules.new/nixos/common/base.nix
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  powerManagement.cpuFreqGovernor = "ondemand"; # hopefully fix low cpu freq
  #  hardware.cpu.amd.updateMicrocode = true; # same

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "America/Los_Angeles";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.substituters = [
    "https://hyprland.cachix.org"
    "https://cache.flox.dev"
    "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" # Corrected Hyprland key
    "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
    "nix-community.cachix.org-1:mB9FSh9xQBNtfPKv2zntfNAxZ/7ITrQA3bFxIf/acADf4z68QUS+Njp/PVhvKK/l"
  ];

  zramSwap.enable = true;
  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024;
      priority = -1;
    }
  ];

  networking.networkmanager.enable = true;

}