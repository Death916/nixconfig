{ config, pkgs, lib, hmLib, ... }:

let
  tmuxaiPackageDir = ../pkgs/tmuxai;
  tmuxai-pkg = pkgs.callPackage tmuxaiPackageDir {};
in
{
  home.username = "death916";
  home.homeDirectory = "/home/death916";

  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  home.packages = with pkgs; [
    fastfetch
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
    tmuxai-pkg
    obsidian
    element-desktop
    ghostty
    manix
  ];

  programs.git = {
    enable = true;
    userName = "death916";
    userEmail = "mail@trentnelson.dev";
    extraConfig = {
      credential.helper = "store";
    };
  };

  programs.atuin = {
    enable = true;
    settings = {
      search_mode = "fuzzy";
    };
  };

  programs.starship = {
  enable = true;
  settings = {
    add_newline = false;
    aws.disabled = true;
    gcloud.disabled = true;
    line_break.disabled = true;

    conda = {
      truncation_length = 1;
      format = ''[$symbol$environment]($style) '';
      symbol = " ";
      style = "green bold";
      ignore_base = false;
      disabled = false;
    };

    env_var = {
      variable = "FLOX_PROMPT_ENVIRONMENTS";
      format = "[flox:$env_value]($style) ";
      style = "purple bold";
      disabled = false;
    };

    format = ''$directory $git_branch $conda$env_var$cmd_duration$status$character'';
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
    };
  };

  home.sessionVariables = {
  };

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}

