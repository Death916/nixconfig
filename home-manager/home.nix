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
    ./hyprland.nix # Add this line to import your Hyprland configuration
    ./theme.nix # Import the stylix theme configuration
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
    cowsay
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
    halloy
    tmux
    nextcloud-client
    obsidian
    element-desktop
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
    cava
    fedistar
    yazi
  ];

  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      window-save-state = "always";
    };

  };

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
        format = ''[$symbol$environment]($style) '';
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

      format = ''$nix_shell$directory $git_branch $conda$env_var$time$cmd_duration$status$character'';
    };
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
  };

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

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';
    shellAliases = {
      k = "kubectl";
      pimox = "tailscale ssh pimox";
      homelab = "tailscale ssh homelab";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
      nh-push = "/home/death916/Documents/nix-config/scripts/nh-push";
    };
  };

  programs.zellij.enable = true;
  programs.halloy.enable = true;
  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor-fhs;
  };

  programs.btop.enable = true;

  programs.lazygit.enable = true;
}
