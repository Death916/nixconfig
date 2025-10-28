# ~/nixconfig/modules.new/nixos/laptop/user.nix
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
      "networkmanager"
      "video"
      "plugdev"
    ];
  };
}
