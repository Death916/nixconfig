{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../modules/media/arr-suite.nix
    ../modules/smb.nix
    ../modules/nixos/homelab/networking.nix
    ../modules/nixos/homelab/services.nix
    ../modules/nixos/common/base.nix
    ../modules/nixos/homelab/user.nix
    ../modules/nixos/common/tailscale.nix
  ];

  config = {
    # Use linux_zen kernel for performance improvements as recommended in Kernel.md
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

    zramSwap.enable = lib.mkForce false;

    boot.kernelParams = [
      "zswap.enabled=1"
      "zswap.compressor=zstd"
      "zswap.max_pool_percent=20"
      "processor.max_cstate=1"
    ];

    boot.kernel.sysctl = {
      "vm.swappiness" = 30;
      "vm.vfs_cache_pressure" = 100;
      # Use CAKE traffic shaper to prevent lag (bufferbloat) during heavy downloads
      "net.core.default_qdisc" = "cake";
      # Use BBR for better throughput and reduced buffering for media streaming
      "net.ipv4.tcp_congestion_control" = "bbr";
    };

    hardware.cpu.amd.updateMicrocode = true;

    systemd.services.sonarr.after = [ "network-online.target" ];
    systemd.services.sonarr.requires = [ "network-online.target" ];
    systemd.services.radarr.after = [ "network-online.target" ];
    systemd.services.radarr.requires = [ "network-online.target" ];
    systemd.services.prowlarr.after = [ "network-online.target" ];
    systemd.services.prowlarr.requires = [ "network-online.target" ];

    arrSuite.unpackerr.enable = true;
    system.stateVersion = "24.11";

    # Auto-reboot the system if it hangs (5 minute timeout)
    boot.kernelModules = [ "sp5100_tco" ];
    systemd.watchdog.rebootTime = "300s";

    specialisation = {
      stable-kernel.configuration = {
        system.nixos.tags = [ "stable" ];
        boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
        boot.kernelParams = lib.mkForce [ "processor.max_cstate=1" ];
        zramSwap.enable = lib.mkForce false;
      };
    };
  };
}
