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
    useRoutingFeatures = "server";
    package = unstablePkgs.tailscale;
  };

  networking.firewall.checkReversePath = "loose";
}
