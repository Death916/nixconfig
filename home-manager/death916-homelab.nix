# ~/nixconfig/home-manager/death916-homelab.nix.new
{
  config,
  pkgs,
  lib,
  inputs,
  unstablePkgs,
  ...
}:

{
  imports = [ ../modules/home-manager/common.nix ];

  home.username = "death916";
  home.homeDirectory = "/home/death916";
  home.stateVersion = "24.11";
  programs.bash.enable = true;

  home.packages = with pkgs; [
    fastfetch
    wget
    systemctl-tui
    gemini-cli
    fzf
    eza
    unstablePkgs.qwen-code
  ];

  programs.bash.shellAliases = {
    nh-push = "/home/death916/nixconfig/scripts/nh-push";
    l = "eza -alh --icons";
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      l = "eza -alh --icons";
    };
    functions = {
      nh-push = {
        body = ''
          /home/death916/nixconfig/scripts/nh-push $argv
        '';
        description = "Wrapper for nh that runs git pull and git push on success";
      };
    };
  };

  programs.zellij = {
    enable = true;
    settings = {
      theme = "tokyo-night-dark";
      default_mode = "normal";
      default_shell = "${pkgs.fish}/bin/fish";
      default_layout = "compact";
      mouse_mode = true;
      on_force_close = "detach";
      scrollback_buffer_size = 10000;
      copy_command = "wl-copy";
      attach_to_session = true;
      session_serialization = true;
      serialize_pane_viewport = true;
      scrollback_lines_to_serialize = 10000;
      support_kitty_keyboard_protocol = true;
      show_startup_tips = true;
    };
    extraConfig = ''
      plugins {
        about location="zellij:about"
        compact-bar location="zellij:compact-bar" {
          tooltip "F1"
        }
        configuration location="zellij:configuration"
        filepicker location="zellij:strider" {
          cwd "/"
        }
        plugin-manager location="zellij:plugin-manager"
        session-manager location="zellij:session-manager"
        status-bar location="zellij:status-bar"
        strider location="zellij:strider"
        tab-bar location="zellij:tab-bar"
        welcome-screen location="zellij:session-manager" {
          welcome_screen true
        }
      }
    '';
  };
}
