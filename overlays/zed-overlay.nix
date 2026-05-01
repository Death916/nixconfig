final: prev: {
  # We only override zed-editor-fhs to ensure the FHS version is used
  # and we don't pollute the environment with a non-FHS version.
  zed-editor-fhs = let
    zed-v1-binary = prev.stdenv.mkDerivation rec {
      pname = "zed-editor-binary";
      version = "1.0.0";

      src = let
        sources = {
          "x86_64-linux" = {
            url = "https://github.com/zed-industries/zed/releases/download/v${version}/zed-linux-x86_64.tar.gz";
            hash = "sha256-2aad4b35481bdb0ed055fd6b402edbf216ffcb8af6b244069eec4b06a311d72f";
          };
          "aarch64-linux" = {
            url = "https://github.com/zed-industries/zed/releases/download/v${version}/zed-linux-aarch64.tar.gz";
            hash = "sha256-6b76782d51cb8533578d10024187948c2ce1b4173346e9cdd4cd89b12b3c11b0";
          };
        };
        source = sources.${prev.system} or (throw "Unsupported system: ${prev.system}");
      in
      prev.fetchurl {
        inherit (source) url hash;
      };

      dontBuild = true;

      nativeBuildInputs = [ prev.autoPatchelfHook ];

      buildInputs = with prev; [
        stdenv.cc.cc.lib
        libGL
        xorg.libX11
        xorg.libXcursor
        xorg.libXi
        xorg.libXrandr
        alsa-lib
        libxcb
        libxkbcommon
        wayland
        vulkan-loader
        openssl
        dbus
        fontconfig
        freetype
      ];

      installPhase = ''
        mkdir -p $out
        cp -r * $out/
        
        # Rename to zeditor to match user preference and avoid ZFS conflict
        if [ -f $out/bin/zed ]; then
          mv $out/bin/zed $out/bin/zeditor
        fi
      '';
    };
  in
  prev.buildFHSEnv {
    name = "zeditor";
    targetPkgs = pkgs: with pkgs; [
      zed-v1-binary
      # Essential runtime and LSP dependencies
      nodejs
      python3
      zlib
      openssl
      stdenv.cc.cc
      curl
    ];
    runScript = "zeditor";

    # Add extra metadata so it looks like the real package
    extraInstallCommands = ''
      mkdir -p $out/share/applications
      if [ -f ${zed-v1-binary}/share/applications/zed.desktop ]; then
        cp ${zed-v1-binary}/share/applications/zed.desktop $out/share/applications/zeditor.desktop
        substituteInPlace $out/share/applications/zeditor.desktop \
          --replace "Exec=zed" "Exec=$out/bin/zeditor" \
          --replace "Icon=zed" "Icon=zeditor" \
          --replace "Name=Zed" "Name=Zed (FHS)"
      fi
      
      # Copy icons
      mkdir -p $out/share/icons
      cp -r ${zed-v1-binary}/share/icons/* $out/share/icons/ || true
    '';
  };
}
