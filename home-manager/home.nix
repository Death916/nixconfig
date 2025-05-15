# ~/Documents/nix-config/home-manager/home.nix
{ config, pkgs, lib, ... }: # These arguments are provided by Home Manager

let
  # Path to the directory containing the tmuxai package's default.nix
  # This path is relative to THIS home.nix file.
  # From home-manager/ up to nix-config/, then down into pkgs/tmuxai/
  tmuxaiPackageDir = ../pkgs/tmuxai;

  # Let pkgs.callPackage handle the import and argument passing for the derivation
  tmuxai-pkg = pkgs.callPackage tmuxaiPackageDir {
    # No explicit arguments like `cacert` needed here,
    # pkgs.callPackage will find `cacert = pkgs.cacert` automatically.
  };

  # Path to your tmuxai configuration template
  tmuxaiConfigTemplatePath = ../pkgs/tmuxai/tmuxai-config.yaml;
in
{
  home.username = "death916";
  home.homeDirectory = "/home/death916";

  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  home.packages = with pkgs; [
    # ... (your other packages from before) ...
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
    tmux # tmuxai needs this
    nextcloud-client
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })

    # Add the tmuxai package
    tmuxai-pkg
  ];

  programs.git = {
    enable = true;
    userName = "death916";
    userEmail = "mail@trentnelson.dev";
    extraConfig = {
      credential.helper = "store";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
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

  # tmuxai configuration file
  xdg.configFile."tmuxai/config.yaml" = {
    # Use the `lib` passed to this module, which includes Home Manager's helpers
    source = lib.mkOutOfStoreSymlink tmuxaiConfigTemplatePath;
  };

  # Environment variables for tmuxai (e.g., API key)
  # Manage secrets securely!
  home.sessionVariables = {
    # TMUXAI_OPENROUTER_API_KEY = "your-secret-key-here";
  };

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
