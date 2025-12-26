# ~/nixconfig/modules.new/home-manager/common.nix
{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "death916";
        email = "mail@trentnelson.dev";
      };
      credential.helper = "store";
    };
  };

  programs.tmux.enable = true;

  programs.helix = {
    enable = true;
    settings = {
      # theme = "autumn_night_transparent"; # Managed by stylix
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
    extraPackages = [ pkgs.python3Packages.python-lsp-server ];
  };

  programs.atuin = {
    enable = true;
    settings = {
      search_mode = "fuzzy";
    };
  };

  home.sessionVariables = {
    EDITOR = "hx";
  };

  programs.home-manager.enable = true;
}
