# ~/nixconfig/home-manager/home.nix.new
{
  config,
  pkgs,
  unstablePkgs,
  lib,
  hmLib,
  ...
}:

let
  tmuxaiPackageDir = ../pkgs/tmuxai;
  tmuxai-pkg = pkgs.callPackage tmuxaiPackageDir { };
in
{
  imports = [
    ../modules/home-manager/common.nix
    ./hyprland.nix
    ./waybar.nix
    ./theme.nix # Import the stylix theme configuration
    ./halloy.nix
  ];

  home.username = "death916";
  home.homeDirectory = "/home/death916";

  # xresources.properties = {
  #   "Xcursor.size" = 16;
  #   "Xft.dpi" = 172;
  # };
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    nnn
    zip
    xz
    unzip
    p7zip
    ripgrep
    jq
    yq-go
    eza
    fzf
    mtr
    iperf3
    dnsutils
    ldns
    aria2
    socat
    nmap
    ipcalc
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg
    nix-output-monitor
    glow
    btop
    iotop
    iftop
    strace
    ltrace
    lsof
    sysstat
    lm_sensors
    ethtool
    pciutils
    usbutils
    waveterm
    tmux
    nextcloud-client
    obsidian
    manix
    aichat
    wl-clipboard
    unstablePkgs.gemini-cli
    zellij
    microsoft-edge
    fastfetch
    golly # alife/gameoflife sim
    asciiquarium # fishies in my term
    vlc
    # jellyfin-media-player
    syncterm
    tradingview
    mdcat
    bash-completion
    pamixer
    brightnessctl
    nautilus
    strawberry
    gcr # gnome keyring prompter
    # libsForQt5.kdeconnect-kde
    kdePackages.kdeconnect-kde
    restic-browser
    fedistar
    thunderbird
    pavucontrol
    meli
    w3m-full
    newsboat
    hypnotix
    obsidian
    pokemon-colorscripts
    awscli2
    unstablePkgs.qwen-code
    unstablePkgs.tauon
  ];

  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    settings = {
      window-save-state = "always";
      initial-command = "fish";
      # include = "config/css";
      keybind = "global:cmd+backquote=toggle_quick_terminal";
    };
  };

  xdg.configFile."ghostty/css".text = ''
    headerbar {
      min-height: 24px;
      padding: 0;
      margin: 0;
    }

    tabbar tabbox {
      margin: 0;
      padding: 0;
      min-height: 10px;
      background-color: #1a1a1a;
      font-family: monospace;
    }

    tabbar tabbox tab {
      margin: 0;
      padding: 0;
      color: #9ca3af;
      border-right: 1px solid #374151;
    }

    tabbar tabbox tab:selected {
      background-color: #2d2d2d;
      color: #ffffff;
    }

    tabbar tabbox tab label {
      font-size: 13px;
    }
  '';

  services.udiskie = {
    enable = true;
    settings = {
      # workaround for
      # https://github.com/nix-community/home-manager/issues/632
      program_options = {
        file_manager = "${pkgs.nautilus}";
      };
    };
  };
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;

      time = {
        disabled = false;
        format = "at [$time]($style) ";
        style = "dimmed green";
      };

      conda = {
        truncation_length = 1;
        format = "[$symbol$environment]($style) ";
        symbol = " ";
        style = "green bold";
        ignore_base = false;
        disabled = false;
      };
      nix_shell = {
        disabled = false;
        symbol = "❄️ ";
        style = "blue bold";
        format = "[$symbol($state)]($style) ";
      };

      env_var = {
        variable = "FLOX_PROMPT_ENVIRONMENTS";
        format = "[flox:$env_value]($style) ";
        style = "purple bold";
        disabled = false;
      };

      format = "$nix_shell$directory $git_branch $conda$env_var$time$cmd_duration$status$character";
    };
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
  };
  programs.firefox.enable = true;
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 12;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };
  services.gnome-keyring.enable = true;

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhsWithPackages (
      ps: with ps; [
        rustup
        zlib
        openssl.dev
        pkg-config
        cargo
      ]
    );
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      l = "eza -alh --icons";
    };
    functions = {
      nh-push = {
        body = ''
          /home/death916/Documents/nix-config/scripts/nh-push $argv
        '';
        description = "Wrapper for nh that runs git pull and git push on success";
      };
    };
    shellInit = ''
      pokemon-colorscripts -r
    '';
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
      pokemon-colorscripts -r
    '';
    shellAliases = {
      k = "kubectl";
      pimox = "tailscale ssh pimox";
      homelab = "tailscale ssh homelab";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
      nh-push = "/home/death916/Documents/nix-config/scripts/nh-push";
      l = "eza -alh --icons";
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
      copy_clipboard = "system";
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
  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor-fhs;
  };

  programs.btop.enable = true;
  programs.yazi = {
    enable = true;
    settings = {
      show_hidden = true;
    };
  };
  programs.cava.enable = true;
  programs.cavalier.enable = true;
  programs.lazygit.enable = true;
  # programs.obsidian.enable = true;
  programs.element-desktop.enable = true;

  home.file.".w3m/config".text = "display_image 1";

  programs.newsboat = {
    enable = true;
    extraConfig = ''
      urls-source "miniflux"
      miniflux-url "http://orac:8086"
      miniflux-login "death916"
      miniflux-passwordfile "/etc/nixos/secrets/minifluxpassword"

      # Macro 'w' to open in w3m with image support
      macro w set browser "w3m -o display_image=1 %u"; open-in-browser; set browser "newsboat-browser"
    '';
    autoFetchArticles = {
      enable = true;
      onCalendar = "daily";
    };
    autoReload = true;
    autoVacuum = {
      enable = true;
      onCalendar = "weekly";
    };
  };

  programs.eza.enable = true;
  programs.waveterm.enable = true;
}
