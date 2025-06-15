# ./home-manager/death916-homelab.nix
{ config, pkgs, lib, inputs, ... }:

{
  home.username = "death916";
  home.homeDirectory = "/home/death916";

  # Basic shell configuration (can be more elaborate)
  programs.bash.enable = true;
  programs.git = {
    enable = true;
    userName = "death916";
    userEmail = "mail@trentnelson.dev";
    extraConfig = {
    credential.helper = "store";
    };
};

  # Server-specific tools or dotfiles for death916
  programs.tmux.enable = true; # Example from your repo image

  # Example: Different shell prompt or aliases for server environment
  # programs.bash.shellAliases = {
  #   ll = "ls -alh";
  #   update-system = "sudo nixos-rebuild switch --flake /etc/nixos#homelab";
  # };


  programs.helix = {
    enable = true;
    settings = {
      theme = "autumn_night_transparent";
      editor = {
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
        true-color = true;
        soft-wrap = {
          enable = true;
        };
      };
    };
    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = lib.getExe pkgs.nixfmt-rfc-style;
      }
      # Python configuration
      {
        name = "python";
        language-servers = [ "pylsp" ];
        auto-format = true;
      }
    ];
    themes = {
      autumn_night_transparent = {
        "inherits" = "autumn_night";
        "ui.background" = { };
      };
    };
    extraPackages = [
      pkgs.python3Packages.python-lsp-server # Required for pylsp
    ];
  };
  
  programs.atuin = {
    enable = true;
    settings = {
      search_mode = "fuzzy";
    };
  };
  
  home.packages = with pkgs; [
    # Any user-specific packages for death916 on the server
    fastfetch
    wget
    
  ];

  # Keep this consistent with your system's state version
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
