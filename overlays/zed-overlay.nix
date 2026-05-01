final: prev: {
  zed-editor = prev.zed-editor.overrideAttrs (old: rec {
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

    # Skip building from source since we're using the official binary
    dontBuild = true;

    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
      prev.autoPatchelfHook
    ];

    buildInputs = (old.buildInputs or [ ]) ++ (with prev; [
      stdenv.cc.cc.lib
      libGL
      libX11
      libXcursor
      libXi
      libXrandr
    ]);

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r * $out/

      # Rename binary to 'zeditor' to avoid conflict with ZFS and match nixpkgs convention
      if [ -f $out/bin/zed ]; then
        mv $out/bin/zed $out/bin/zeditor
      fi

      # Fix up the desktop file paths
      if [ -f $out/share/applications/zed.desktop ]; then
        substituteInPlace $out/share/applications/zed.desktop \
          --replace "Exec=zed" "Exec=$out/bin/zeditor" \
          --replace "Icon=zed" "Icon=$out/share/icons/hicolor/512x512/apps/zed.png"
      fi
      runHook postInstall
    '';

    # Remove parts of the original derivation that aren't needed for binary install
    cargoDeps = null;
    cargoHash = null;
    postInstall = "";
    checkPhase = "";
    doCheck = false;
  });
}
