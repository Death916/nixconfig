# ~/nixconfig/modules.new/nixos/common/tailscale.nix
{
  config,
  pkgs,
  ... 
}:

{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };

  networking.firewall.checkReversePath = "loose";
}
