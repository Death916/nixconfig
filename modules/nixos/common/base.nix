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
  hardware.cpu.amd.updateMicrocode = true; # same

  time.timeZone = "America/Los_Angeles";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}
