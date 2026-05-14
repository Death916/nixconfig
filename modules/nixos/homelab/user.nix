# ~/nixconfig/modules.new/nixos/homelab/user.nix
{
  config,
  pkgs,
  primaryUser,
  ...
}:

{
  users.users.${primaryUser} = {
    isNormalUser = true;
    home = "/home/${primaryUser}";
    description = "${primaryUser}";
    extraGroups = [
      "wheel"
      "media_services"
      "nextcloud"
      "docker"
      "qbittorrent"
      "incus-admin"
      "libvirtd"
    ];
  };
}
