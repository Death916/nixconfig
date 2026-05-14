{ pkgs, primaryUser, ... }:

{
  programs.fish.enable = true;
  users.users.${primaryUser}.shell = pkgs.fish;
}
