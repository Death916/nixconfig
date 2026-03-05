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
    powerManagement.enable = false;
    open = true; # Use the open-source kernel module (recommended for RTX 20+ cards)
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    nvidiaPersistenced = true; # Correct way to enable persistence mode
  };

  services.pipewire.enable = true;
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
