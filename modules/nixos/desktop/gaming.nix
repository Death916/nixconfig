{
  config,
  pkgs,
  unstablePkgs,
  ...
}:
{
  # NVIDIA & Audio
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true; # Required for HDMI/DP audio on many cards
    powerManagement.finegrained = false;
    open = true; # Use the open-source kernel module (recommended for RTX 20+ cards)
    nvidiaSettings = true;
    # Switched to beta driver because stable (595.71.05) fails to compile on Linux 7.2 due to strncpy changes in os-interface.c
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    nvidiaPersistenced = true; # Correct way to enable persistence mode
  };
  nixpkgs.config.allowUnfree = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  security.rtkit.enable = true;

  # Gaming & BTRFS Packages
  programs.steam.enable = true;
  programs.gamemode.enable = true;
  environment.systemPackages = with pkgs; [
    steam
    lutris
    gamemode
    prismlauncher
    vlc
    discord
    btrfs-progs
    unstablePkgs.btrfs-assistant
    snapper
    wowup-cf
    # (proton-ge-custom.override { version = "GE-Proton9-6"; })
  ];

  # Snapper Setup
  services.snapper.configs.home = {
    SUBVOLUME = "/home";
    allowUsers = [ "death916" ];
    TIMELINE_CREATE = true;
  };
  services.snapper.configs.nix = {
    SUBVOLUME = "/nix";
    allowUsers = [ "death916" ];
    TIMELINE_CREATE = true;
  };
}
