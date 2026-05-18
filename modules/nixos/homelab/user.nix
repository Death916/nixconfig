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
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJDXyTcemkngWQA90CXc5P97QsF7Lcl+SBLCdggkgCt9 death916@death-pc"
    ];
  };
}
