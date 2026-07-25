{ osConfig, lib, ... }:

{
  wayland.windowManager.hyprland.settings = {
    monitor =
      if (osConfig.networking.hostName == "death-pc") then [
        "desc:Acer Technologies R240HY T4BAA0012400,1920x1080,-1920x0,1"
        "desc:BNQ BenQ EL2870U 26M05467SL0,2560x1440,0x0,1"
        "desc:WAM U24C 0000000000001,1920x1080,2560x0,1"
      ] else if (osConfig.networking.hostName == "nix-asus") then [
        "eDP-1, 2880x1800@120, 0x0, 1.25"
      ] else [
        ",preferred,auto,1"
      ];

    workspace =
      if (osConfig.networking.hostName == "death-pc") then [
        "1, monitor:desc:BNQ BenQ EL2870U 26M05467SL0"
        "2, monitor:desc:Acer Technologies R240HY T4BAA0012400"
        "3, monitor:desc:WAM U24C 0000000000001"
      ] else [ ];
  };
}
