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
}
