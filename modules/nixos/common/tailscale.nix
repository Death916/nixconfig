# ~/nixconfig/modules.new/nixos/common/tailscale.nix
{
  config,
  pkgs,
  unstablePkgs,
  ...
}:

{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    package = unstablePkgs.tailscale;
  };

  networking.firewall.checkReversePath = "loose";
}
