# ~/Documents/nix-config/home-manager/home.nix
{ config, pkgs, lib, ... }: # Use THIS `lib` for mkOutOfStoreSymlink

let
  # --- DEBUGGING TRACE STATEMENTS (Keep these for now) ---
  _ = builtins.trace "\n--- Debugging Home Manager Libs (home.nix LET block) ---" null;
  _ = builtins.trace "Attributes in top-level lib: ${builtins.toString (builtins.attrNames lib)}" null;
  _ = builtins.trace "Is mkOutOfStoreSymlink in top-level lib? ${toString (builtins.hasAttr "mkOutOfStoreSymlink" lib)}" null;
  _ = builtins.trace "Attributes in config.lib: ${builtins.toString (builtins.attrNames config.lib)}" null;
  _ = builtins.trace "Is mkOutOfStoreSymlink in config.lib? ${toString (builtins.hasAttr "mkOutOfStoreSymlink" config.lib)}" null;
  _ = builtins.trace "--- End Debugging Home Manager Libs ---\n" null;
  # --- END DEBUGGING ---

  tmuxaiPackageDir = ../pkgs/tmuxai;
  tmuxai-pkg = pkgs.callPackage tmuxaiPackageDir {};
  tmuxaiConfigTemplatePath = ../pkgs/tmuxai/tmuxai-config.yaml;
in
{
  _ = tmuxai-pkg; # Ensures let block (and traces) are evaluated

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
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
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

  xdg.configFile."tmuxai/config.yaml" = {
    # Using the top-level `lib` passed to this module
    source = lib.mkOutOfStoreSymlink tmuxaiConfigTemplatePath;
  };

  home.sessionVariables = {
    # TMUXAI_OPENROUTER_API_KEY = "your-secret-key"; # Manage securely
  };

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
