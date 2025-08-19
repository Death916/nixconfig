# ~/nixconfig/nixos/homelab.nix.new
{
  imports = [
    ../modules/nextcloud-setup.nix
    ../modules/media/qbittorrent.nix
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
    ../modules/containers/kopia-server.nix
  ];

  config = {
    services.kopia-server.enable = true;
    system.stateVersion = "24.11";
  };
}
