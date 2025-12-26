{
  config,
  pkgs,
  ...
}:
{

  virtualisation.docker.enable = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 10";
    flake = "/home/death916/nixconfig/";
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    htop
    tailscale
    rsync
    multipath-tools
    btop
    wget
    unzip
    manix
  ];
}
