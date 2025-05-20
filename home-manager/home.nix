# ~/Documents/nix-config/home-manager/home.nix
{ config, pkgs, lib, hmLib, ... }: # hmLib is still passed, but we won't use it for config file

let
  tmuxaiPackageDir = ../pkgs/tmuxai;
  tmuxai-pkg = pkgs.callPackage tmuxaiPackageDir {};
  # tmuxaiConfigTemplatePath = ../pkgs/tmuxai/tmuxai-config.yaml; # Not used for now
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
#    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    tmuxai-pkg # Just install the package
    obsidian
    
    ghostty
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
      #auto_sync = true;
      #sync_frequency = "5m";
      #sync_address = "https://api.atuin.sh";
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
      format = "[$symbol$environment]($style) ";
      symbol = " ";
      style = "green bold";
      ignore_base = false;
      disabled = false;
    };

    env_var.flox_active_env = {
      variable = "FLOX_ENV_NAME";
      format = "via [❄️ $env_value](bold blue) ";
      description = "Shows the active Flox environment name";
    };

    # --- MODIFIED FORMAT STRING (Single Line) ---
    format = "$username$hostname$directory$git_branch$git_status$conda$env_var.flox_active_env$nix_shell$cmd_duration$status$character";
    # --- END MODIFIED FORMAT STRING ---
  };
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

  # --- TMUXAI CONFIGURATION REMOVED FOR NOW ---
  # xdg.configFile."tmuxai/config.yaml" = {
  #   source = hmLib.mkOutOfStoreSymlink tmuxaiConfigTemplatePath;
  # };

  home.sessionVariables = {
    # TMUXAI_OPENROUTER_API_KEY = "your-secret-key"; # Manage securely
  };

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
