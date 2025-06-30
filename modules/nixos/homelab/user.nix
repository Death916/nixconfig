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
    extraGroups = [ "wheel" "media_services" "nextcloud" "docker" "qbittorent" "incus-admin" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCte9KjJUSn4xBPEKCk9QER6+jF+C0uBatVl27zIamYsryyHdFrmqK2DAg7OhqTHqzjxID6sp6d57MsJqOUAtwXbUDMLffqBSerUxfTm+1SPDrhL0GSvo0QVjMLVseOEq8d2qXgW1R7dIk412VbO5e9SAump5aJOHI/SzT6VLoUczalmqrjnDacWQMeLu/TSOZHcfrhjYSg+b1xbc1vHp6C4obOb8JIj/anAieT/1P36MhlNW79ow6PWenLemBYeeezFrKtESF1oMc8jmcxogzgLamlqhKYAHlKhOuBF6u0nRneI5IPDbbMF5zwEv5szCEKj8XZJVYUk8uUg7ARyppjcA7yAXuaNKBNxa7tfjqWrDWOACn97ufE5FFJt0XH5JzkXcDh96K8ZSZaWxMRu2s+GlIu/1F415xtVfe1d79HYkWke/ewaQ4NqgOt8f7wRvyzabpQZDzkaXO0UoK65O2HyUur33XWCEmV+1pB6BrS8pD+1I4Tvbnc+rOgtHTTRfKqezKqZmaErEOxClBwvWjvn0PzhGSoClTGXPjhl239/sH0JGY09dTBh8GtAVbfv+jFO6nm6aR7O/OwSaohY3uOdRo8XyxJr4XyGAaBNRdm6BUJRnB4W51J49IQBZzIe2NUkNMHeUT4jkxFpfhkujnSFw2ZnOLkERpwkltAlbwuLw== tavn1992@gmail.com"
    ];
  };
}
