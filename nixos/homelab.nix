# ~/nixconfig/nixos/homelab.nix.new
{
  imports = [
    ../modules/nextcloud-setup.nix
    ../modules/media/qbittorrent.nix
    ../modules/media/arr-suite.nix
    #  ../modules/home-assistant.nix
    #   ../modules/home-assistant-vm.nix
    ../modules/vms/incus-base.nix
    ../modules/smb.nix
    #    ../modules/opencloud.nix
    ../modules/nixos/homelab/networking.nix
    ../modules/nixos/homelab/services.nix
    ../modules/nixos/common/base.nix
    ../modules/nixos/homelab/user.nix
    ../modules/nixos/common/tailscale.nix
    ../modules/vms/ha-control-script.nix
    ../modules/vms/homeassistant-vm.nix
    ../modules/vms/ha-deploy-script.nix
  ];
}
