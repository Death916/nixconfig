# ~/nixconfig/nixos/homelab.nix.new
{
  imports = [
    ../modules/nextcloud-setup.nix
    ../modules/media/arr-suite.nix
    #  ../modules/home-assistant.nix
    ../modules/vms/homeassistant-vm.nix
    ../modules/vms/incus-base.nix
    ../modules/smb.nix
    #    ../modules/opencloud.nix
    ../modules/nixos/homelab/networking.nix
    ../modules/nixos/homelab/services.nix
    ../modules/nixos/common/base.nix
    ../modules/nixos/homelab/user.nix
    ../modules/nixos/common/tailscale.nix
  ];

  config = {
    boot.kernelParams = [ "processor.max_cstate=1" ];
    hardware.cpu.amd.updateMicrocode = true;
    # Wait for network to be online
    # systemd.services.NetworkManager-wait-online.enable = true;

    # Service dependencies
    systemd.services.sonarr.after = [ "network-online.target" ];
    systemd.services.sonarr.requires = [ "network-online.target" ];
    systemd.services.radarr.after = [ "network-online.target" ];
    systemd.services.radarr.requires = [ "network-online.target" ];
    systemd.services.prowlarr.after = [ "network-online.target" ];
    systemd.services.prowlarr.requires = [ "network-online.target" ];
    systemd.services.nextcloud-setup.after = [
      "network-online.target"
      "postgresql.service"
    ];
    systemd.services.nextcloud-setup.requires = [
      "network-online.target"
      "postgresql.service"
    ];

    arrSuite.unpackerr.enable = true;
    system.stateVersion = "24.11";

    # Auto-reboot the system if it hangs (5 minute timeout)
    boot.kernelModules = [ "sp5100_tco" ];
    systemd.watchdog.rebootTime = "300s";
  };
}
