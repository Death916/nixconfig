{ config, pkgs, ... }:

{
  # Enable PipeWire for audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Enable Polkit for privilege escalation
  security.polkit.enable = true;

  # Enable Fonts
  fonts.fontDir.enable = true;

  # Enable xdg-desktop-portal-hyprland for proper portal functionality
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
}
