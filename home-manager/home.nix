# ~/Documents/nix-config/home-manager/home.nix
{ config, pkgs, lib, hmLib, ... }:
# ... (rest of your usual Nix setup, packages, git, atuin, etc.) ...
in
{
  # ... (home.username, home.homeDirectory, xresources, packages, git, atuin) ...

  programs.starship = {
  enable = true;
  settings = {
    add_newline = false;
    # For this test, we can comment out other modules if needed, but let's try with them first.
    aws.disabled = true;
    gcloud.disabled = true;
    line_break.disabled = true;

    conda = {
      truncation_length = 1;
      format = ''[$symbol$environment]($style) '';
      symbol = " ";
      style = "green bold";
      ignore_base = false;
      disabled = false;
    };

    # Test 1: Display the USER environment variable
    env_var.current_user_display = {
      variable = "USER"; # This variable should always be set
      format = "[USER: $env_value] "; # Simple format with a clear prefix and trailing space
      disabled = false;
    };

    # Main format string - includes the test module
    format = ''$directory $git_branch $conda$env_var_current_user_display$nix_shell$cmd_duration$status$character'';
  };
};

  # ... (rest of your emacs, alacritty, bash, etc. config) ...
  home.stateVersion = "24.11"; # Ensure this matches your setup
  programs.home-manager.enable = true;
}
